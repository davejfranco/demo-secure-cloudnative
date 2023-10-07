#ECR container registry
#Repo for the demo app
resource "aws_ecr_repository" "app" {
  name                 = "${var.name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false #this is a demo, so we don't need to scan
  }
}

#Repo for the demo agent
resource "aws_ecr_repository" "agent" {
  name                 = "${var.name}-agent"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false #this is a demo, so we don't need to scan
  }
}