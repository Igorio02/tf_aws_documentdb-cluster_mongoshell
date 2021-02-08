output "ec2_public_ip_address" {
  value = aws_eip.my_static_ip.public_ip
}
output "endpoint" {
  value       = module.documentdb-cluster.endpoint
  description = "Endpoint of the DocumentDB cluster"
}
