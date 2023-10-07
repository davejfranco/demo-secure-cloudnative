resource "random_password" "this" {
  length = 24
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}-secrets"
  #kms_key_id = module.secrets_manager_kms.key_id
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    DB_USERNAME = sensitive("admin")
    DB_PASSWORD = sensitive(random_password.this.result)
  })
}