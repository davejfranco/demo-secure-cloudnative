# resource "aws_db_parameter_group" "main_db" {
#   name        = "sign-prod-db"
#   description = "Parameter Group - Penneo Sign - Production DB"
#   family      = "mysql5.7"

#   parameter {
#     apply_method = "immediate"
#     name         = "general_log"
#     value        = "1"
#   }
#   parameter {
#     apply_method = "immediate"
#     name         = "long_query_time"
#     value        = "2"
#   }
#   parameter {
#     apply_method = "immediate"
#     name         = "slow_query_log"
#     value        = "1"
#   }
# }

# # Production Application master instance
# #tfsec:ignore:enable-iam-auth
# resource "aws_db_instance" "sign_prod_master" {
#   # Instance config
#   identifier = "sign-prod-master"

#   instance_class      = "db.m5.4xlarge"
#   skip_final_snapshot = true
#   deletion_protection = true

#   # Engine configuration
#   engine         = "mysql"
#   engine_version = "5.7.42"

#   # Storage
#   storage_type          = "gp3"
#   allocated_storage     = 2048
#   max_allocated_storage = 8192

#   # MySQL config
#   parameter_group_name = aws_db_parameter_group.sign_prod_db.id
#   username             = "admin"
#   password             = "p3nn30-l33t-p4ssw0rd" #tfsec:ignore:general-secrets-no-plaintext-exposure

#   # Encryption
#   storage_encrypted = true
#   kms_key_id        = module.prod_rds_primary.key_arn

#   # Network
#   db_subnet_group_name   = aws_db_subnet_group.prod_sign_private.name
#   vpc_security_group_ids = [aws_security_group.sign_prod_master_rds_access.id]

#   # Monitoring
#   monitoring_interval             = 60
#   performance_insights_enabled    = true
#   performance_insights_kms_key_id = module.prod_rds_performance_insights.key_arn

#   maintenance_window = "Sun:01:00-Sun:02:30"

#   apply_immediately = false

#   # Backup
#   backup_retention_period = 7 #48 hours for point in time recovery, just in case
#   copy_tags_to_snapshot   = true

#   # Tags
#   tags = merge(local.default_tags, {
#     Name = "sign-prod-db-master"
#   })

#   lifecycle {
#     ignore_changes = [
#       username,
#       password,
#       max_allocated_storage,
#     ]
#   }
# }

# resource "aws_db_subnet_group" "prod_sign_private" {
#   name        = "penneo-sign-production-private"
#   description = "Private Subnets"
#   subnet_ids  = module.vpc.intra_subnets
# }

# resource "aws_db_subnet_group" "prod_sign_public" {
#   name        = "penneo-sign-production-public"
#   description = "Public Subnets"
#   subnet_ids  = module.vpc.public_subnets
# }

# resource "aws_security_group" "sign_prod_master_rds_access" {
#   name        = "penneo-sign-prod-db-master"
#   description = "Penneo Sign - production - Master DB" #to avoid replacement 
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "Inbound - Legacy Production VPC"
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "TCP"
#     cidr_blocks = local.private_subnets
#   }

#   egress {
#     description = "Outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }