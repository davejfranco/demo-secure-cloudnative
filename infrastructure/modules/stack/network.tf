#Module network
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway #We need high availability for private subnets in production

  tags = var.tags
}
