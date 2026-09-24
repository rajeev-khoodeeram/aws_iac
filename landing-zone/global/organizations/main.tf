terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Root management region
}

# 1. Enable AWS Organizations (Must be executed from your AWS Management/Root account)
resource "aws_organizations_organization" "bank_org" {
  feature_set = "ALL"
}

# 2. Create Core Platform OU (Equiv. to Azure Platform Management Group)
resource "aws_organizations_organizational_unit" "core" {
  name      = "Core-Platform"
  parent_id = aws_organizations_organization.bank_org.roots[0].id
}

# 3. Create Workloads OU (Equiv. to Azure Landing Zones Management Group)
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.bank_org.roots[0].id
}

# 4. Create Security/Logging OU (Equiv. to Azure Security/Logging Management Group)
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security-Compliance"
  parent_id = aws_organizations_organization.bank_org.roots[0].id
}

output "org_id" {
  value = aws_organizations_organization.bank_org.id
}