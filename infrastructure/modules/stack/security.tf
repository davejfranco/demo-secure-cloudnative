module "key_pair" {
  count   = var.create_key_pair ? 1 : 0
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = "${var.name}-key"
  create_private_key = true

  tags = var.tags
}