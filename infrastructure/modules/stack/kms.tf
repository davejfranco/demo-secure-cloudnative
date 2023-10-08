#EKS node group encryption
module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description = "Customer managed key to encrypt ECS nodes group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    #     # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.ecs_cluster.cluster_arn,
    module.autoscaling.autoscaling_group_arn
  ]

  # Aliases
  aliases = ["eks/${var.name}/ebs"]

  tags = var.tags
}


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

