# How to create/deploy/test on traditional AWS infrastructure

Traditional AWS infrastructure is simply two VMs in a private subnet on AWS, with a third VM in a public subnet to act as a bastion host. The bastion host is used to SSH into the private VMs for configuration, and it's also used to run the load test against the web server.

1. Log into the AWS console and create/download a new keypair in the EC2 key pair settings [here](https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#KeyPairs:)
1. Fix the permissions on your keyfile, wherever your downloaded it:

```bash
# limit permissions on your keyfile so SSH doesn't get angry
chmod 600 /path/to/keyfile.pem
```

1. In the [IAM settings](https://us-east-1.console.aws.amazon.com/iam/home?region=us-west-2#/users), create a new user with programmatic access and attach the `AmazonEC2FullAccess` policy to it. Once you've created the user, create the access keys for that user (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) and save them in a safe place.

1. Export these API credentials as environment variables in the same shell that you're going to run the terraform commands in.

```bash
export AWS_ACCESS_KEY_ID="yourkey"
export AWS_SECRET_ACCESS_KEY="yoursecretkey"
```

1. Enter the directory that contains the terraform module you want to use. This presumes you're already inside the project directory.

```bash
cd infrastructure/aws-traditional
```

1. Run terraform

Enter the path to your keypair and your current IP address when prompted, or put them in a terraform.tfvars file so you won't be prompted each time you run terraform.

```bash
terraform init
terraform plan
terraform apply
```

You should see output like this, after the terraform run completes:

```bash
Outputs:

bastion_public_ip = "54.201.244.160"
db_server_private_ip = "10.0.2.170"
web_server_private_ip = "10.0.2.147"
```

I'll refer to these as `$BASTION_IP`, `$DB_HOST`, and `$WEB_HOST` from now on.
Feel free to export them as shell variables on all servers you log into for this test, but remember that you'll need to do this for every new shell.


1. Log into your bastion server, and bring your key along (`ssh-add` and `-A`):

```bash
ssh-add /path/to/keyfile.pem
ssh -A alpine@BASTION_IP
```

### Start postgres on your DB host

From your bastion host, SSH into your db host.

```bash
ssh $DB_HOST
```

Start the docker container.

```bash
doas docker run --rm --name pg_stressedout \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=stressedout \
  -d -p 5432:5432 postgres
```

If you want to stop/recreate this container (for example to run the test against the second web app), just stop it:

```bash
doas docker stop pg_stressedout
```


### Test the Elixir webapp

#### On the web server

Clone the application and build a docker container.

```bash
cd
git clone https://github.com/groovemonkey/stressedout-elixir.git
cd stressedout-elixir
doas docker build -t stressedout-elixir .
```


The Phoenix web application requires a secret string to start, so if you have elixir, mix, and phoenix installed locally, you can generate such a string with `mix phx.gen.secret`. The vast majority of you will want to skip that, and just use this one that I've pre-generated for you (I suspect you can use any 64-character UTF-8 string but I'm not sure):

```bash
export YOUR_SECRET_KEY_BASE=tNbgJQPPiNOTSECURENOTSECURENOTSECUREWWH+aPL3FQ+u/f0H42zjVt1Ll0LZ
```

This is used for things like signing cookies and other webapp-related things, but this is a test application so it doesn't matter. Obviously, don't go using that on your production Phoenix web applications.

Ensure that the `$DB_SERVER` is set to the database server's IP address before running the following command.

```bash
doas docker run --rm --name stressedout \
  -e DATABASE_URL=ecto://postgres:postgres@$DB_SERVER/stressedout \
  -e SECRET_KEY_BASE=$YOUR_SECRET_KEY_BASE \
  -e PHX_HOST=localhost \
  -p 80:4000 stressedout-elixir
```

#### On the bastion host

Create the lua script for `wrk`:

```bash
cat << EOF >> test_endpoints.lua
math.randomseed(12345)

-- List of endpoints
local endpoints = { "/", "/dynamic", "/read", "/write" }

-- Function to generate a random request
request = function()
	-- Select a random endpoint
	local endpoint = endpoints[math.random(#endpoints)]
	-- Return the request object
	return wrk.format("GET", endpoint)
end
EOF
```

Ensure that the `$WEB_HOST` shell variable is set. Now you're ready to seed the database (via the webapp) and run the load test!

```bash
# Seed with data
curl http://$WEB_HOST/api/seed

# Confirm that everything works (you should see HTML)
curl http://$WEB_HOST/read

# Run the test
wrk -t12 -c400 -d30s -s ./test_endpoints.lua http://$WEB_HOST/
```

When you're done, you can stop the container.

```bash
doas docker stop stressedout
```

### Test the Go webapp

#### On the web server

Clone the application and build a binary.

```bash
cd
git clone https://github.com/groovemonkey/stressedout-go.git
cd stressedout-go
go mod tidy
go build .
```

Ensure that the `$DB_SERVER` is set to the database server's IP address before running the following commands. (If you just ran a test with Elixir, ensure that you stop/remove and recreate the postgres container on the DB server as well, with `doas docker stop pg_stressedout`.)

Export the environment variables that the Go web application expects to be started with.

```bash
export POSTGRES_ADDR=$DB_SERVER:5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=stressedout
```

Run the Go web application:

```bash
./stressedout-go
```

#### On the bastion host

Ensure that the `$WEB_HOST` shell variable is set, and ensure that you've appended :8080 to it (otherwise you'll have to manually add :8080 to all the curl and wrk URLs below).

```bash
export WEB_HOST=web_host_ip:8080
```

Now you're ready to seed the database (via the webapp) and run the load test!

```bash
# Create the database schema
curl http://$WEB_HOST/firstrun

# Seed with data
curl http://$WEB_HOST/seed

# Confirm that everything works (you should see HTML)
curl http://$WEB_HOST/read

# Run the test
wrk -t12 -c400 -d30s -s ./test_endpoints.lua http://$WEB_HOST/
```

