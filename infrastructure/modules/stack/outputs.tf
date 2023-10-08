output "ssh_private_key" {
  value = var.create_key_pair ? module.key_pair.private_key_pem : null
}

output "db_instance_arn" {
  value = aws_db_instance.main_db.arn
}

output "ecs_service_arn" {
  value = module.ecs_service.id
}

output "ecs_service_name" {
  value = module.ecs_service.name
}

output "ecs_service_task_role_arn" {
  value = module.ecs_service.tasks_iam_role_arn
}

output "ecs_service_task_exec_role_arn" {
  value = module.ecs_service.task_exec_iam_role_arn
}