data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid    = "ServiceAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_secretsmanager_secret.this.arn]
  }
}

resource "aws_iam_policy" "ecs_secret_access" {
  name   = "${var.name}-ecs-secret-access"
  policy = data.aws_iam_policy_document.ecs_assume_role.json
}
resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role       = module.ecs_service.task_exec_iam_role_name
  policy_arn = aws_iam_policy.ecs_secret_access.arn
}
