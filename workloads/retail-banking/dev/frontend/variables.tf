variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "RetailProd AWS account ID"
  type        = string
  default     = "967172220355"
}

variable "vpc_id" {
  description = "Retail Banking Dev VPC"
  type        = string
  default     = "vpc-065ebcb8e2b3aafc8"
}

variable "public_subnets" {
  description = "Public subnets for the ALB"
  type        = list(string)

  default = [
    "subnet-0a339e58c225b5a12",
    "subnet-0e1521b9a379e1d41"
  ]
}

variable "private_subnets" {
  description = "Private subnets for ECS"
  type        = list(string)

  default = [
    "subnet-0aa6db94b850c197e",
    "subnet-09bb6e8788746119f"
  ]
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "retail-banking-frontend"
}

variable "environment" {
  description = "Application environment"
  type        = string
  default     = "dev"
}

variable "container_port" {
  description = "Node.js application port"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}