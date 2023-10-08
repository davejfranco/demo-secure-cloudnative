#Check this https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-sns-alarms/blob/0.12.3/examples/complete/main.tf

resource "aws_sns_topic" "sns_topic" {
  name              = "${var.name}-sns-topic"
  display_name      = "SNS Topic for ${var.name} ECS Service"
  tags              = var.tags
  kms_master_key_id = "alias/aws/sns"
}

module "ecs_cloudwatch_sns_alarms" {
  source = "github.com/davejfranco/terraform-aws-ecs-cloudwatch-sns-alarms"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = "${var.name}-ecs-service"

  cpu_utilization_high_threshold          = var.cpu_utilization_high_threshold
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period             = var.cpu_utilization_high_period
  cpu_utilization_low_threshold           = var.cpu_utilization_low_threshold
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period              = var.cpu_utilization_low_period

  memory_utilization_high_threshold          = var.memory_utilization_high_threshold
  memory_utilization_high_evaluation_periods = var.memory_utilization_high_evaluation_periods
  memory_utilization_high_period             = var.memory_utilization_high_period
  memory_utilization_low_threshold           = var.memory_utilization_low_threshold
  memory_utilization_low_evaluation_periods  = var.memory_utilization_low_evaluation_periods
  memory_utilization_low_period              = var.memory_utilization_low_period

  cpu_utilization_high_alarm_actions = [aws_sns_topic.sns_topic.arn]
  cpu_utilization_high_ok_actions    = [aws_sns_topic.sns_topic.arn]
  cpu_utilization_low_alarm_actions  = [aws_sns_topic.sns_topic.arn]
  cpu_utilization_low_ok_actions     = [aws_sns_topic.sns_topic.arn]

  memory_utilization_high_alarm_actions = [aws_sns_topic.sns_topic.arn]
  memory_utilization_high_ok_actions    = [aws_sns_topic.sns_topic.arn]
  memory_utilization_low_alarm_actions  = [aws_sns_topic.sns_topic.arn]
  memory_utilization_low_ok_actions     = [aws_sns_topic.sns_topic.arn]

  #context = module.this.context
}