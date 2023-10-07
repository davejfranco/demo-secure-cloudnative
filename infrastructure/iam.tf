#this needs to be deployed beforehand
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

#ECR Policy to allow Github Actions to push to ECR
data "aws_iam_policy_document" "gh_image_manager_trust_policy" {
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
        "repo:davejfranco/demo-secure-cloudnative:ref:refs/tags/*",
        "repo:davejfranco/demo-secure-cloudnative:ref:refs/heads/master",
      ]
      variable = "${replace(data.aws_iam_openid_connect_provider.github.url, "https://", "")}:sub"
    }
  }
}

# This is the role Github Actions will assume for chart deployments
resource "aws_iam_role" "github_image_manager" {
  name               = "gh-image-manager"
  assume_role_policy = data.aws_iam_policy_document.gh_image_manager_trust_policy.json
}

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

resource "aws_iam_role_policy_attachment" "github_image_manager_ecr_auth_token" {
  role       = aws_iam_role.github_image_manager.name
  policy_arn = aws_iam_policy.ecr_auth_token.arn
}