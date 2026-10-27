output "nat_sg_id" {
  value = aws_security_group.nat_sg.id
}

output "nat_asg_ids" {
  value = [for asg in aws_autoscaling_group.nat_asg : asg.id]
}

output "nat_eips" {
  value = { for k, eip in aws_eip.nat_eip : k => eip.public_ip }
}
output "nat_asg_names" {
  description = "NAT AutoScaling Group names per AZ"
  value       = { for k, asg in aws_autoscaling_group.nat_asg : k => asg.name }
}
output "nat_eni_ids" {
  description = "NAT ENI IDs per AZ"
  value       = { for k, eni in aws_network_interface.nat_eni : k => eni.id }
}

