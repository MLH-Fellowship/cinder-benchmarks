terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "bench_run" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "bench_run"
  }
}

resource "aws_eip" "bench_run_ip" {
  instance = aws_instance.bench_runner.id
  vpc      = true
}

resource "aws_internet_gateway" "bench_run_gw" {
  vpc_id = aws_vpc.bench_run.id

  tags = {
    Name = "bench_run_gw"
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block        = cidrsubnet(aws_vpc.bench_run.cidr_block, 3, 1)
  vpc_id            = aws_vpc.bench_run.id
  availability_zone = "us-west-2a"
}

resource "aws_route_table" "bench_run_route_table" {
  vpc_id = aws_vpc.bench_run.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bench_run_gw.id
  }

  tags = {
    Name = "bench_run_route_table"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.bench_run_route_table.id
}

resource "aws_security_group" "ingress_all" {
  name   = "allow_all_sg"
  vpc_id = aws_vpc.bench_run.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_instance" "bench_runner" {
  ami                    = "ami-830c94e3"
  instance_type          = "t2.micro"
  key_name               = "bench-runner"
  vpc_security_group_ids = ["${aws_security_group.ingress_all.id}"]
  subnet_id              = aws_subnet.subnet1.id

  tags = {
    Name = "BenchmarkingEC2Runner"
  }
}

