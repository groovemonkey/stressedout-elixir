terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security Groups
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-test-bastion-sg"
  }
}

resource "aws_security_group" "private" {
  name        = "private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-test-private-sg"
  }
}

# EC2 Instances
# TODO break out separate alpine datasource
# https://alpinelinux.org/cloud/
data "aws_ami" "ubuntu" {
  most_recent = true
  # owners      = ["099720109477"] # Canonical
  owners = ["538276064493"] # Alpine


  filter {
    name = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
    # 24.04 doesn't exist for some reason in us-west-2
    # values = ["ubuntu/images/hvm-ssd/ubuntu-24.04-amd64-server-*"]
    values = ["alpine-3.20.2-x86_64-bios-cloudinit-r0"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "load-test-bastion"
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c6i.2xlarge" # 8 vCPUs, 16 GiB RAM, intel CPU. ~$0.34/hr
  key_name      = var.key_name

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
  }

  user_data = file("${path.module}/install_docker.sh")

  tags = {
    Name = "load-test-web-server"
  }
}

resource "aws_instance" "db_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c6i.4xlarge" # 16 vCPUs, 32 GiB RAM, intel CPU. ~$0.68/hr
  key_name      = var.key_name

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
  }

  user_data = file("${path.module}/install_docker.sh")

  tags = {
    Name = "load-test-db-server"
  }
}

# Output
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "web_server_private_ip" {
  value = aws_instance.web_server.private_ip
}

output "db_server_private_ip" {
  value = aws_instance.db_server.private_ip
}
