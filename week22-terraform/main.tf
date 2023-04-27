# Configure AWS provider with the desired region
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create 2 public subnets
resource "aws_subnet" "public" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
  map_public_ip_on_launch = true
}

# Create 2 private subnets
resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.0.${count.index + 3}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table for public subnets with a route to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public route table with public subnets
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a security group for web servers allowing HTTP and SSH traffic
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create 2 EC2 instances using the ec2 module
module "ec2" {
  source = "./modules/ec2"

  instance_count    = 2
  instance_type     = "t2.micro"
  ami_id            = "ami-03c7d01cf4dedc891"
  subnet_id         = aws_subnet.public.*.id
  key_name          = "mbp16"
  security_group_id = aws_security_group.web.id
}

# Create a security group for RDS allowing MySQL traffic from the web security group
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow inbound MySQL traffic"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL traffic from the web security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a subnet group for RDS instances using the private subnets
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private.*.id
}

# Create an RDS MySQL instance
resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "yourpassword" # Replace with a secure password
  db_subnet_group_name = aws_db_subnet_group.rds.name

  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
}

output "public_ips" {
  value = module.ec2.public_ips
}
