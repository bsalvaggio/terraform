provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Terraform = "true"
    Project   = "Jenkins"
    Name      = "Jenkins VPC"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "Jenkins Subnet"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Jenkins Internet Gateway"
  }
}

# Create a route table and associate it with the VPC
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Jenkins Route Table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Create a security group for the Jenkins EC2 instance
resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins-security-group"
  description = "Security group for Jenkins EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  # Allow traffic on port 22 (SSH) from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic on port 8080 (Jenkins) from any IP address
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic on port 80 (HTTP) from any IP address
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic on all ports and protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]

  tags = {
    Terraform = "true"
    Project   = "Jenkins"
    Name      = "my-instance"
  }

  user_data = file("jenkinsuserdata.sh")
}

# Create an S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "billsjenkins_artifacts" {
  bucket = var.bucket_name
  tags = {
    Name = "BIlls Jenkins Artifacts Bucketwk20"
  }
}
output "instance_public_ip" {
  value       = aws_instance.instance.public_ip
  description = "The public IP address of the EC2 instance"
  depends_on  = [aws_instance.instance]
}