locals {
  #General Settings
  aws_region = "us-east-1"
  name       = "n26"
  environment = "demo"
  tags = {
    "Owner"       = "Infrastructure Team"
    "Environment" = "Demo"
  }

  #Network
  vpc_cidr        = "10.0.0.0/16"
  az              = slice(data.aws_availability_zones.available.names, 0, length(local.private_subnets))
  private_subnets = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  intra_subnets   = ["10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
  public_subnets  = ["10.0.70.0/24", "10.0.80.0/24", "10.0.90.0/24"]

  #EKS
  cluster_version = "1.27"
}

