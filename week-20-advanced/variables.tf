variable "aws_region" {
  description = "The AWS region to deploy the infrastructure in."
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet."
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "The Amazon Machine Image (AMI) ID for the EC2 instance."
  default     = "ami-04581fbf744a7d11f" # Amazon Linux 2 AMI 
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "billsjenkins_artifacts."
  default     = "billsjenkins-artifacts-bucketwk20"
}