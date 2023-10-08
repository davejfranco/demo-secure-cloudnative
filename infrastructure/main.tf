module "demo" {
  source = "./modules/stack"

  name      = var.name
  region    = "us-east-1"
  dr_region = "us-east-2"

  #Network config
  vpc_cidr = "172.16.0.0/16"
  private_subnets = [
    "172.16.10.0/24",
    "172.16.20.0/24",
    "172.16.30.0/24"
  ]

  intra_subnets = [
    "172.16.40.0/24",
    "172.16.50.0/24",
    "172.16.60.0/24"
  ]

  public_subnets = [
    "172.16.70.0/24",
    "172.16.80.0/24",
    "172.16.90.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true #We need redundancy NAT for production

  #ECS config
  ecs_ami_id = data.aws_ami.ecs_custom.image_id

  #EKS config
  # cluster_version                 = "1.27"
  # cluster_endpoint_public_access  = true
  # cluster_endpoint_private_access = true

  # node_group_ami_id         = data.aws_ami.eks_custom.image_id
  # node_group_min_size       = 1
  # node_group_max_size       = 2
  # node_group_desired_size   = 1
  # node_group_instance_types = ["t3.medium"]
  # node_group_volume_size    = 30

}