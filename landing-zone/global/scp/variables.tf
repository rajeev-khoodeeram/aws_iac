variable "workloads_ou_id" {
  description = "AWS Organizations OU ID for the Workloads OU"
  type        = string
}

variable "core_platform_ou_id" {
  description = "AWS Organizations OU ID for the Core Platform OU"
  type        = string
}

variable "security_compliance_ou_id" {
  description = "AWS Organizations OU ID for the Security Compliance OU"
  type        = string
}