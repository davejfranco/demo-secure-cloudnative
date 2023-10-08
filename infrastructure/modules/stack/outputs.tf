output "ssh_private_key" {
  value = var.create_key_pair ? module.key_pair.private_key_pem : null
}

output "db_instance_arn" {
  value = aws_db_instance.main_db.arn
}
