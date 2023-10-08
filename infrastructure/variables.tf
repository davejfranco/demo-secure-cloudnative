variable "tags" {
  type        = map(string)
  description = "Infrastructure tags"
  default = {
    "Owner"       = "Infrastructure Team"
    "Environment" = "Demo"
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "dr_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "n26"
}
