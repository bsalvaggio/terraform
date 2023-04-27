output "ec2_public_ips" {
  value       = module.ec2.public_ips
  description = "Public IP addresses of the EC2 instances"
}
