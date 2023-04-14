variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  default     = "t2.micro"
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  default     = 5
}
