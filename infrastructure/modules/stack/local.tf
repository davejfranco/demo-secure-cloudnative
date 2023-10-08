locals {
  azs            = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnets))
  cluster_name   = "${var.name}-ecs"
  container_name = "${var.name}-container"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.cluster_name}
    ECS_LOGLEVEL=debug
    ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.tags)}
    ECS_ENABLE_TASK_IAM_ROLE=true
    EOF
  EOT

  db = {
    name                    = "${var.name}-db"
    username                = var.db_username
    password                = random_password.this.result
    multi_az                = true 
    pi                      = true
    publicly_accessible     = false
    backup_retention_period = 0
    monitoring_interval     = 0
  }
}