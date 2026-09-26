# variable "aws_region" {
#   type    = string
#   default = "us-east-1"
# }

# variable "vpc_cidr" {
#   type    = string
#   default = "10.100.0.0/16"
# }


# ==============================================================================
# AWS Enterprise Landing Zone - Platform Networking Variables
# ==============================================================================

variable "aws_region" {
  description = "AWS region where the enterprise networking foundation is deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the core enterprise VPC"
  type        = string
}

