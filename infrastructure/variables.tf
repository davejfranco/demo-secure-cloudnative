variable "tags" {
  type        = map(string)
  description = "Infrastructure tags"
  default = {
    "Owner"       = "Infrastructure Team"
    "Environment" = "Demo"
  }
}