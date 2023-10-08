data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

# data "aws_ami" "eks_default" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${var.cluster_version}-v*"]
#   }
# }

data "aws_ami" "ecs_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20230912-x86_64-ebs"]
  }
}