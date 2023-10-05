#This will garantee that all EBS volumes are encrypted by default
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}
