terraform {
  required_version = ">= 0.12, < 0.13.6"
}

provider "aws" {
  region = "us-east-2"
  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

resource "aws_instance" "example" {
  ami = "ami-0139bc7111bd80cbc"
  instance_type = "t2.micro"
  subnet_id     = "subnet-7e85fa32"
  vpc_security_group_ids = [aws_security_group.instance.id]

  # start a bare-bones web server with a hello page
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    protocol = "tcp"
    to_port = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}