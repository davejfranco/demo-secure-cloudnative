module "stack_backup" {
  source = "github.com/davejfranco/terraform-aws-backup"

  drp_region = var.dr_region #This will replate backups to a disaster recovery region

  vault_name = "${var.name}-backup-vault"
  rule_name  = "${var.name}-backup-rule"
  schedule   = "cron(0 12 * * ? *)"

  plan_lifecycle = {
    cold_storage_after = 30
    delete_after       = 365
  }

  copy_lifecycle = {
    cold_storage_after = 30
    delete_after       = 365
  }

  target_resources_arn = [
    aws_db_instance.main_db.arn,
  ]
}