output "vpc_id" {
  description = "Retail Dev VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Retail Dev VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability Zones"
  value       = module.vpc.azs
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private application subnet IDs"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "Private database subnet IDs"
  value       = module.vpc.database_subnets
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}