# Stressedout

A small web application that is designed to be stress-tested on various infrastructures, to measure performance.

## Testing instructions

My goal is to provide everything you need to test this on various cloud/metal-as-a-service providers, using different example architectures. Here's what exists so far:

1. [AWS Traditional](infrastructure/aws-traditional/README.md): a traditional "cloud VM" setup with a bastion host, and fairly powerful Web and Database server VMs.

### TODO

- AWS Serverless (Lambda + RDS)
- Hetzner: metal-as-a-service, running super powerful (and cheap!) dedicated servers. Then I want to do a cost comparison of running this on AWS vs Hetzner.
- For this elixir app (doesn't apply to the [Go application](https://github.com/groovemonkey/stressedout-go)), maybe I could do something really funky, like using an in-memory clustered database and an Elixir cluster -- mnesia or something like that?

### Sample results

On AWS, against the following instances:

- web: `c6i.2xlarge` (8 vCPUs, 16 GiB RAM, intel CPU. ~$0.34/hr)
- db: `c6i.4xlarge` (16 vCPUs, 32 GiB RAM, intel CPU. ~$0.68/hr)

```bash
wrk -t12 -c800 -d60s -s ./test_endpoints.lua http://10.0.2.107/
Running 1m test @ http://10.0.2.107/
  12 threads and 800 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   295.37ms  308.88ms   1.47s    82.47%
    Req/Sec   332.53    302.12     1.92k    72.49%
  221187 requests in 1.00m, 1.46GB read
  Non-2xx or 3xx responses: 77027
Requests/sec:   3680.34
Transfer/sec:     24.79MB
```

Lots of errors due to a low db timeout setting, but this test got close to saturating the instances:

Web cpu: 75%
Web mem: 1GB mem
DB cpu: 75%
DB Memory: ~500MB (the dataset wasn't huge, so it's not memory constrained)

In another test, I was seeing no errors and 2537.87 requests/sec, which is about half of what the Go application was doing for the same test on the same infrastructure.

#### Comparison to Go

For comparison, the much-more-minimal Go application got 3222.26 requests/sec (but also lots of errors) with the same test.

Both applications did a bit better with 400 connections instead of 800:
Elixir: 2537.87 requests/sec, no errors.
Go: 4887.66 requests/sec, but with lots of errors.

The go webapp did so by perfectly saturating all 16 cores on the database box, and barely giving the web application CPUs a workout at ~35-40% CPU, and using a comparable amount of memory as Elixir (both around 1GB - 1.2GB)

I'll keep experimenting. It would be fun to get this Elixir app up to 10k requests/sec.

## Run as a container

If you just want to run this locally as a container and see what kind of throughput you get on your own machine, I wrote a docker-compose file to make it easy.

```bash
docker compose -f docker-compose.yml up --force-recreate --build --remove-orphans
```

The container config is written so that each container automatically tries to run migrations as it starts up.

## If you don't like docker compose for some reason...Local Dev Setup

Run the postgres container:

```bash
docker run --rm --name pg_stressedout \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=stressedout \
  # this way of setting max connections doesn't work
  # -e POSTGRES_MAX_CONNECTIONS=1000 \
  # but using -N max_conns does
  -d -p 5432:5432 postgres -N 400
```

Connect to pg with `psql -h localhost -p 5432 -U postgres -d stressedout`

Delete with `docker kill pg_stressedout`

## Seed

Just load the seed endpoint:

`curl http://localhost:4000/api/seed`

## Routes

- [Static pages](http://localhost:4000/static)
- [Dynamic pages (no DB)](http://localhost:4000/dynamic)
- [Dynamic pages (db reads)](http://localhost:4000/read)
- [Dynamic pages (db writes)](http://localhost:4000/write)

## Perf test output

This is just a random attempt on a somewhat busy-with-other-stuff 2023 Apple Macbook Pro M2 Max with 32GB of memory (12 processors of various speeds). Also the application was running in dev mode, so not with prod settings or containerized.

```bash
➜  perf git:(main) ✗ wrk -t12 -c400 -d30s -s ./test_endpoints.lua http://localhost:4000
Running 30s test @ http://localhost:4000
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    23.51ms   35.13ms 239.94ms   74.80%
    Req/Sec   701.47      1.75k   11.44k    90.89%
  251084 requests in 30.10s, 2.01GB read
  Socket errors: connect 157, read 29839, write 0, timeout 0
  Non-2xx or 3xx responses: 251084
Requests/sec:   8341.74
```

Woof, look at those errors. I think it ran out of file handles. Anyway, it looks totally different on "real" test infrastructure (AWS, etc.).

## Thoughts

- When the database was the limiting factor (the c5.xlarge I was originally using choked immediately), Elixir returned a lot more errors. I think it's because of a suboptimal read timeout setting in Phoenix -- 100ms timeout on reads is way too low. I'll fix this by jiggling :queue_target and :queue_interval in Phoenix.

- It might be cool to use bandit instead of cowboy: <https://github.com/mtrudel/bandit?tab=readme-ov-file> (is it faster? My guess is "not really" since I don't think that the web serving is a huge part of the time spent by the app.)
