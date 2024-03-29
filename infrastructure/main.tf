module "demo" {
  source = "./modules/stack"

  name = var.name

  region    = var.region
  dr_region = var.dr_region

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
  ecs_ami_id = data.aws_ami.ecs_default.image_id #change this if you need a custom ami id

}