#Database KMS Keys
module "db_main_key" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "1.5.0"
  description = "KMS key for at-rest encryption for RDS (production)"

  # Aliases
  aliases                 = ["rds/${var.name}/main"]
  aliases_use_name_prefix = true

  bypass_policy_lockout_safety_check = false
  multi_region                       = true #this will create a replica in each region

  key_statements = [
    {
      sid = "UsageRDSService"

      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["rds.amazonaws.com"]
        }
      ]
    },
  ]

  key_owners = [data.aws_caller_identity.current.arn]
}

module "db_replica_key" {

  providers = {
    aws = aws.dr
  }

  source      = "terraform-aws-modules/kms/aws"
  version     = "1.5.0"
  description = "KMS key for at-rest encryption for RDS (production)"

  # Aliases
  aliases                 = ["rds/${var.name}/replica"]
  aliases_use_name_prefix = true

  create_replica = true

  bypass_policy_lockout_safety_check = false
  multi_region                       = true
  primary_key_arn                    = module.db_main_key.key_arn

  key_statements = [
    {
      sid = "UsageRDSService"

      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["rds.amazonaws.com"]
        }
      ]
    },
  ]

  key_owners = [data.aws_caller_identity.current.arn]
}

module "rds_performance_insights" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "1.5.0"
  description = "KMS key for RDS Performance Insights (${var.environment})"

  # Aliases
  aliases                 = ["rds/${var.name}/performance-insights"]
  aliases_use_name_prefix = true

  bypass_policy_lockout_safety_check = false
  multi_region                       = true

  key_statements = [
    {
      sid = "UsageRDSService"

      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["rds.amazonaws.com"]
        }
      ]
    },
    {
      sid    = "KMSKeyUsage"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]

      resources = ["*"]

      principals = [{
        identifiers = [data.aws_caller_identity.current.arn]
        type        = "AWS"
      }]

      condition = [
        {
          variable = "kms:EncryptionContext:aws:pi:service"
          test     = "ForAnyValue:StringEquals"
          values   = ["rds"]
        },
        {
          variable = "kms:EncryptionContext:service"
          test     = "ForAnyValue:StringEquals"
          values   = ["pi"]
        },
        {
          variable = "kms:ViaService"
          test     = "StringEquals"
          values   = ["rds.${data.aws_region.current.name}.amazonaws.com"]
        }
      ]
    }
  ]

  key_owners = [data.aws_caller_identity.current.arn]
}

