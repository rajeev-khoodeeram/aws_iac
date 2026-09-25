terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type = string
}

# Customer Managed KMS Key for Core Encryption
resource "aws_kms_key" "landing_zone_key" {
  description             = "KMS key for enterprise landing zone encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
  }
}

# Enable Amazon GuardDuty Threat Detection
resource "aws_guardduty_detector" "primary" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }

  tags = {
    Environment = "Production"
  }
}

output "kms_key_arn" {
  value = aws_kms_key.landing_zone_key.arn
}