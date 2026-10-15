variable "aws_region" {
  description = "AWS region for Retail Banking Dev"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for Retail Banking Dev VPC"
  type        = string
  default     = "10.110.0.0/16"
}