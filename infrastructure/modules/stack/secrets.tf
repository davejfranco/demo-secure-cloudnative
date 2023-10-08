resource "random_password" "this" {
  length = 24
}

#Secrets once created cannot be recreated with the same name
resource "random_string" "random" {
  length = 4
  lower  = true
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}1"
  #kms_key_id = module.secrets_manager_kms.key_id
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    DB_HOSTNAME = sensitive(aws_db_instance.main_db.address) #CHANGE THIS TO YOUR RDS ENDPOINT
    DB_USERNAME = sensitive(var.db_username)
    DB_PASSWORD = sensitive(random_password.this.result)
  })
}