#this needs to be deployed beforehand
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

#ECR Policy to allow Github Actions to push to ECR
data "aws_iam_policy_document" "gh_trust_policy" {
  statement {
    sid     = "GHActionsPushHelm"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${replace(data.aws_iam_openid_connect_provider.github.url, "https://", "")}:aud"
    }

    condition {
      test = "StringLike"
      values = [
        #This ensures that GHA can only be used to push to the ECR repo in master and tags (releases)
        "repo:${var.github_repo}:ref:refs/tags/*", #Adjust this to the account
        "repo:${var.github_repo}:ref:refs/heads/main",
      ]
      variable = "${replace(data.aws_iam_openid_connect_provider.github.url, "https://", "")}:sub"
    }
  }
}

# This is the role Github Actions will assume for chart deployments
resource "aws_iam_role" "github_manager" {
  name               = "gh-manager"
  assume_role_policy = data.aws_iam_policy_document.gh_trust_policy.json
}

# This is the policy that allows the role to push to ECR
data "aws_iam_policy_document" "ecr_auth_token" {
  statement {
    sid    = "MinimalPermissions"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken" // Allows identity to request a token to authenticate against registries.
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_auth_token" {
  name_prefix = "ecr-auth-token-access-"
  policy      = data.aws_iam_policy_document.ecr_auth_token.json
}

resource "aws_iam_role_policy_attachment" "github_manager_ecr_auth_token" {
  role       = aws_iam_role.github_manager.name
  policy_arn = aws_iam_policy.ecr_auth_token.arn
}

#ECR access policy
data "aws_iam_policy_document" "ecr_access_policy" {
  statement {
    sid    = "ReadWrite"
    effect = "Allow"
    actions = [
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:ListImages",
      "ecr:ListTagsForResource"
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.github_manager.arn,
      ]
    }
  }
}

#Packer access policy
#https://developer.hashicorp.com/packer/integrations/hashicorp/amazon#iam-task-or-instance-role
data "aws_iam_policy_document" "packer_access_policy" {
  statement {
    sid    = "PackerPermissions"
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "packer_access_policy" {
  name   = "packer-access-policy"
  policy = data.aws_iam_policy_document.packer_access_policy.json
}

resource "aws_iam_role_policy_attachment" "packer_access_policy" {
  role       = aws_iam_role.github_manager.name
  policy_arn = aws_iam_policy.packer_access_policy.arn
}

#ECS update service access
data "aws_iam_policy_document" "ecs_access_policy" {
  statement {
    sid    = "ecsTaskDef"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "UpdateService"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = [module.demo.ecs_service_arn]
  }
  statement {
    sid    = "PassRolesInTaskDefinition"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      module.demo.ecs_service_task_role_arn,
      module.demo.ecs_service_task_exec_role_arn
    ]
  }
}

resource "aws_iam_policy" "ecs_access_policy" {
  name   = "ecs-access-policy"
  policy = data.aws_iam_policy_document.ecs_access_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_access_policy" {
  role       = aws_iam_role.github_manager.name
  policy_arn = aws_iam_policy.ecs_access_policy.arn
}

/*
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"RegisterTaskDefinition",
         "Effect":"Allow",
         "Action":[
            "ecs:RegisterTaskDefinition"
         ],
         "Resource":"*"
      },
      {
         "Sid":"PassRolesInTaskDefinition",
         "Effect":"Allow",
         "Action":[
            "iam:PassRole"
         ],
         "Resource":[
            "arn:aws:iam::<aws_account_id>:role/<task_definition_task_role_name>",
            "arn:aws:iam::<aws_account_id>:role/<task_definition_task_execution_role_name>"
         ]
      },
      {
         "Sid":"DeployService",
         "Effect":"Allow",
         "Action":[
            "ecs:UpdateService",
            "ecs:DescribeServices"
         ],
         "Resource":[
            "arn:aws:ecs:<region>:<aws_account_id>:service/<cluster_name>/<service_name>"
         ]
      }
   ]
}
*/