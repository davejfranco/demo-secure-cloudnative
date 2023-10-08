resource "aws_db_parameter_group" "main_db" {
  name        = "${var.name}-prod-db"
  description = "Parameter Group - ${var.name} - Production DB"
  family      = "mysql8.0"

  parameter {
    apply_method = "immediate"
    name         = "general_log"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "long_query_time"
    value        = "2"
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = "1"
  }
}

# Production Application master instance
#tfsec:ignore:enable-iam-auth
resource "aws_db_instance" "main_db" {
  #count = 0
  # Instance config
  identifier = "${var.name}-prod-master"
  multi_az   = local.db.multi_az

  instance_class      = var.db_instance_class
  skip_final_snapshot = true
  deletion_protection = true

  # Engine configuration
  engine         = "mysql"
  engine_version = "8.0.33" #need to use a datasource to automatically get the latest version

  #   # Storage
  storage_type          = "gp3"
  allocated_storage     = 50
  max_allocated_storage = 100

  # MySQL config
  parameter_group_name = aws_db_parameter_group.main_db.id
  username             = local.db.username
  password             = local.db.password

  # Encryption
  storage_encrypted = true
  #kms_key_id        = module.prod_rds_primary.key_arn

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main_db.name
  vpc_security_group_ids = [aws_security_group.main_db.id]
  publicly_accessible    = local.db.publicly_accessible

  #   # Monitoring
  monitoring_interval          = local.db.monitoring_interval
  performance_insights_enabled = local.db.pi
  #performance_insights_kms_key_id = module.prod_rds_performance_insights.key_arn

  maintenance_window = "Sun:01:00-Sun:02:30"

  apply_immediately = false

  #   # Backup
  backup_retention_period = 7 #48 hours for point in time recovery, just in case
  copy_tags_to_snapshot   = true

  # Tags
  tags = var.tags

  lifecycle {
    ignore_changes = [
      username,
      password,
      max_allocated_storage,
    ]
  }
}

resource "aws_db_subnet_group" "main_db" {
  name        = "${var.name}-production-private"
  description = "Private Subnets"
  subnet_ids  = module.vpc.public_subnets #module.vpc.private_subnets
}

resource "aws_security_group" "main_db" {
  name        = "${var.name}-prod-db-master"
  description = "main_db - production - Master DB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Inbound Private VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    description = "Inbound Public VPC" #Please delete
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}