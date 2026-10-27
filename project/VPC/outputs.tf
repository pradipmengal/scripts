output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Map of public subnets by AZ"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnets" {
  description = "Map of private subnets by AZ"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "private_route_tables" {
  description = "Private route table IDs (per AZ key)"
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}
