data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}


data "aws_ami" "ecs_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20230912-x86_64-ebs"]
  }
}

#If you bake your own AMI, you can use this data source to find it
data "aws_ami" "ecs_custom" {
  most_recent = true
  owners      = [data.aws_caller_identity.current.account_id]

  filter {
    name   = "name"
    values = ["amazon-ecs-custom-ami"]
  }
}