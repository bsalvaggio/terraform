# Configure the S3 backend for storing Terraform state
terraform {
  backend "s3" {
    bucket = "<your_bucket_name>"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
