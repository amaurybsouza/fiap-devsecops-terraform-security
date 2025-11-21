terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
  }
}

provider "aws" {
  # Configuration options
  region                   = "sa-east-1"
  shared_credentials_files = ["/home/amaurybs/.aws/credentials"]
  #profile                  = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  iam_instance_profile = "test"
  monitoring    = true
  ebs_optimized = true
    metadata_options {
      http_endpoint = "enabled"
      http_tokens   = "required"
    }

     root_block_device {
     encrypted     = true
}
  tags = {
    Name = "HelloWorld"
  }
}