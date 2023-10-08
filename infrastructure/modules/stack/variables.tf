variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "demo"
}

variable "environment" {
  type        = string
  description = "Environment of the stack"
  default     = "demo"
}

variable "tags" {
  type        = map(string)
  description = "Infrastructure tags"
  default = {
    "Owner"       = "Infrastructure Team"
    "Environment" = "Demo"
    "Stack"       = "demo"
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "dr_region" {
  type        = string
  description = "Disaster Recovery  region"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "list of private subnets cidr"
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

variable "intra_subnets" {
  type        = list(string)
  description = "list of intra subnets cidr"
  default     = ["10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "list of public subnets cidr"
  default     = ["10.0.70.0/24", "10.0.80.0/24", "10.0.90.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Enable single NAT Gateway"
  default     = true
}

variable "admin_ips" {
  type        = list(string)
  description = "List of IPs to allow SSH access"
  default     = ["0.0.0.0/0"]
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.27"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Enable public access to the cluster endpoint"
  default     = true
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Enable private access to the cluster endpoint"
  default     = true
}

variable "node_group_name" {
  type        = string
  description = "Name of the node group"
  default     = "ng-demo"
}

variable "ecs_ami_id" {
  type        = string
  description = "AMI ID for the node group"
  default     = ""
}

# variable "node_group_min_size" {
#   type        = number
#   description = "Minimum size of the node group"
#   default     = 1
# }

# variable "node_group_max_size" {
#   type        = number
#   description = "Maximum size of the node group"
#   default     = 2
# }

# variable "node_group_desired_size" {
#   type        = number
#   description = "Desired size of the node group"
#   default     = 1
# }

# variable "node_group_instance_types" {
#   type        = list(string)
#   description = "list of instance type allowed in nodegroup"
#   default     = ["t3a.medium"] #AMD
# }

# variable "node_group_volume_size" {
#   type        = number
#   description = "Size of the node group volume"
#   default     = 30
# }

variable "create_key_pair" {
  type        = bool
  description = "Create a key pair for SSH access"
  default     = false
}

#Database
variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "demo"
}

variable "db_username" {
  type        = string
  description = "Username for the database"
  default     = "demouser"
}

variable "db_version" {
  type        = number
  description = "Version of the database"
  default     = 8.0
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for the database"
  default     = "db.t3.micro"
}