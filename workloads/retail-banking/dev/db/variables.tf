
variable "aws_region" {
  description = "AWS region for the database"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC containing ECS and the database"
  type        = string
}

variable "db_subnet_ids" {
  description = "Private database subnets in separate Availability Zones"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ECS application security group allowed to connect to PostgreSQL"
  type        = string
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "retailbanking"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "retailadmin"
}

variable "db_instance_class" {
  description = "RDS instance size for the development lab"
  type        = string
  default     = "db.t3.micro"
}
