# Number of instances to create
variable "instance_count" {}

# Instance type to use for the EC2 instances (e.g., t2.micro, t3.small, etc.)
variable "instance_type" {}

# Amazon Machine Image (AMI) ID for the EC2 instances
variable "ami_id" {}

# List of subnet IDs where the EC2 instances will be created
variable "subnet_id" {}

# Name of the key pair to use for SSH access to the EC2 instances
variable "key_name" {}

# ID of the security group to associate with the EC2 instances
variable "security_group_id" {}

# Define an AWS EC2 instance resource
resource "aws_instance" "this" {
  # The Amazon Machine Image (AMI) ID for the instance
  ami = var.ami_id

  # The instance type, determining its CPU, memory, storage, and networking capacity
  instance_type = var.instance_type

  # The ID of the subnet in which the instance will be launched, using count.index to pick the correct subnet from the list
  subnet_id = var.subnet_id[count.index]

  # The name of the key pair to be used for SSH access to the instance
  key_name = var.key_name

  # The IDs of the security groups to associate with the instance
  vpc_security_group_ids = [var.security_group_id]

  # The path to the user_data.sh script, which will be executed on the instance at launch to install and configure the web server
  user_data = file("${path.module}/userdata.sh")

  # Tags to be applied to the instance, with the Name tag set to a unique value based on the count.index value
  tags = {
    Name = "webserver-${count.index + 1}"
  }

  # The number of instances to create, as specified in the variable 'count'
  count = var.instance_count
}
# Output the Public IP
output "public_ips" {
  value = aws_instance.this.*.public_ip
  description = "The public IP addresses of the created instances"
}
