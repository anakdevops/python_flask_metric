terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "keypair_anakdevops.pem"
}


resource "aws_key_pair" "key_pair" {
  key_name   = "var.key_name"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}


resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name
}


resource "aws_security_group" "anakdevops_sg" {
  name        = "anakdevops_sg"
  description = "Security group for EC2"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "345kjh345kj"
}

resource "aws_instance" "ec2_anakdevops" {
  ami                    = "ami-060e277c0d4cce553"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.anakdevops_sg.id]
  depends_on             = [aws_s3_bucket.my_bucket]

  tags = {
    Name = "ec2_anakdevops"
  }

 user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y s3fs docker.io docker-compose git
              sudo usermod -aG docker ubuntu
              sudo systemctl enable docker
              sudo systemctl start docker
              echo "${var.access_key}:${var.secret_key}" > /etc/passwd-s3fs
              sudo chown root:root /etc/passwd-s3fs
              sudo chmod 600 /etc/passwd-s3fs
              sudo mkdir -p /mnt/s3-bucket
              echo "s3fs#${aws_s3_bucket.my_bucket.bucket} /mnt/s3-bucket fuse _netdev,allow_other 0 0" | sudo tee -a /etc/fstab
              sudo systemctl daemon-reload
              sudo mount -a
              cd /mnt/s3-bucket
              git clone https://github.com/adylimmo/python_flask_metric.git
              cd python_flask_metric
              sudo docker-compose up -d
              EOF

}
