#This is where we control backup of our resources
#If database is encrypted so will be the backup
#Also replicates de vault in case of disaster recovery
#Backups are planed to be done every 12 hours meaning a 12 hours RPO
# module "stack_backup" {
#   source = "github.com/davejfranco/terraform-aws-backup"

#   drp_region = var.dr_region #This will replate backups to a disaster recovery region

#   vault_name = "${var.name}-backup-vault"
#   rule_name  = "${var.name}-backup-rule"
#   schedule   = "cron(0 12 * * ? *)"

#   plan_lifecycle = {
#     cold_storage_after = 30
#     delete_after       = 365
#   }

#   copy_lifecycle = {
#     cold_storage_after = 30
#     delete_after       = 365
#   }

#   target_resources_arn = [
#     module.demo.db_instance_arn, #This is the database we want to backup
#   ]
# }