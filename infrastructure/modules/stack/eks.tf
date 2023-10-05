module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.0"
  cluster_name                    = "${var.name}-eks"
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access #This is best practice for production

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_groups = {

    nodes = {
      name            = var.node_group_name
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size


      force_update_version = true # This will force the node group to update to the current cluster version
      instance_types       = var.node_group_instance_types

      labels = {
        node-type = "internal"
        kind      = "ondemand"
      }

      # taints = [
      #   {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # ]

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_group_volume_size
            volume_type           = "gp3"
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      create_iam_role          = true
      iam_role_name            = "${var.name}-eks-node-group-iam-role"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group role"
      iam_role_tags            = var.tags
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

    }
  }

  tags = var.tags
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}