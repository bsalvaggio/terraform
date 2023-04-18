# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Fetch the default VPC information
data "aws_vpc" "default" {
  default = true
}

# Create a security group allowing HTTP traffic
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a launch configuration for the webserver
resource "aws_launch_configuration" "webserver" {
  name          = "webserver"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  security_groups = [
    aws_security_group.allow_http.id,
  ]

  # User data script to install and start Apache webserver
  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World!" > /var/www/html/index.html
              EOF
}

# Create an Auto Scaling group for the webserver
resource "aws_autoscaling_group" "webserver" {
  name             = "webserver"
  desired_capacity = var.min_size
  min_size         = var.min_size
  max_size         = var.max_size
  vpc_zone_identifier = data.aws_vpc.default.subnet_ids
  launch_configuration = aws_launch_configuration.webserver.name
}

# Fetch the Amazon Linux 2 AMI information
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

# Create an S3 bucket for the backend
resource "aws_s3_bucket" "backend" {
  bucket = "week21"
  acl    = "private"
}

# Output the public IP addresses of the instances in the Auto Scaling group
output "instance_public_ips" {
  value = [
    for instance in aws_autoscaling_group.webserver.instances : instance.public_ip
  ]
  description = "The public IP addresses of the EC2 instances in the Auto Scaling group"
}
