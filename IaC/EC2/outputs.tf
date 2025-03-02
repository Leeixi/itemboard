output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.debian_server.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.debian_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.debian_server.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i /path/to/${var.key_name}.pem admin@${aws_eip.debian_server.public_ip}"
}