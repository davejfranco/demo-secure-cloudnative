packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.7"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "subnet_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name" {
  type    = string
  default = "amazon-eks-node"
}

locals {
  ssh_username  = "ec2-user"  # SSH username
  instance_type = "t3a.micro" # Instance type
  ssh_timeout   = "2h"        # SSH timeout
  ebs_optimized = false       # EBS optimized
  encrypt_boot  = true        # Secure boot 
}

source "amazon-ebs" "eks-worker" {
  ami_name      = var.ami_name
  instance_type = local.instance_type
  region        = var.region

  ssh_username  = local.ssh_username
  ssh_timeout   = local.ssh_timeout
  ebs_optimized = local.ebs_optimized
  subnet_id     = var.subnet_id

  encrypt_boot = local.encrypt_boot
  source_ami_filter {
    filters = {
      name                = "amazon-eks-node-${var.cluster_version}-v*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
}

build {
  name = "demo-eks-ng-custom"
  sources = [
    "source.amazon-ebs.eks-worker"
  ]

  provisioner "file" {
    source      = "../agent/smith.sh"
    destination = "/tmp/smith.sh"
  }

  provisioner "file" {
    source      = "agent.service"
    destination = "/tmp/agent.service"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/smith.sh",
      "sudo mv /tmp/smith.sh /opt/smith.sh",
      "sudo chmod +x /opt/smith.sh",
      "sudo mkdir -p /var/log/agent",
      "sudo mv /tmp/agent.service /etc/systemd/system/agent.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable agent.service",
      "sudo systemctl start agent.service"
    ]
  }
}
