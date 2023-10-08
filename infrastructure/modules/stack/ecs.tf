module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = local.cluster_name


  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false

  autoscaling_capacity_providers = {
    # On-demand instances
    nodes = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 4
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 1
      }

      default_capacity_provider_strategy = {
        weight = 4
        base   = 1
      }
    }
  }

  tags = var.tags
}

# ECS Service
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = "${var.name}-ecs-service"
  cluster_arn = module.ecs_cluster.cluster_arn

  # Task Definition
  requires_compatibilities = ["EC2"]
  capacity_provider_strategy = {
    # On-demand instances
    this = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["nodes"].name
      weight            = 1
      base              = 1
    }
  }

  # Container definition(s)
  container_definitions = {

    (local.container_name) = {
      cpu       = 512
      memory    = 512
      essential = true
      image     = "nginx:1.24-alpine"
      port_mappings = [
        {
          name          = "http"
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "awslogs-${var.name}-ecs",
          awslogs-region        = var.region,
          awslogs-stream-prefix = "awslogs",
          mode                  = "non-blocking",
          max-buffer-size       = "25m"
        }
      }
      memory_reservation = 100
    }
  }


  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = local.container_name
      container_port   = 80
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }

  }

  tags = var.tags
}

#Autoscaling Group
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name     = "${var.name}-asg"
  image_id = var.ecs_ami_id


  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  instance_type              = "t3a.medium"
  use_mixed_instances_policy = false

  security_groups = [
    aws_security_group.ssh_access.id,
    aws_security_group.web_access.id,
  ]

  ignore_desired_capacity_changes = true

  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 80.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label         = "testLabel"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label         = "testLabel"
          }
        }
      }
    }
  }
  user_data = base64encode(local.user_data)

  create_iam_instance_profile = true
  iam_role_name               = "${var.name}-asg-role"
  iam_role_description        = "ECS role for ${var.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  #Storage
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 35    #has to be bigger than 30
        volume_type           = "gp3" #gp3 is the latest generation of gp2
      }
    }
  ]

  #Tags
  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = var.tags
}

#Service
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = var.name

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.web_access.id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = "${var.name}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    },
  ]

  tags = var.tags
}