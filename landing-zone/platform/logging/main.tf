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

data "aws_caller_identity" "current" {}

# Centralized CloudTrail Audit S3 Bucket
resource "aws_s3_bucket" "audit_logs" {
  bucket        = "bank-core-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  bucket                  = aws_s3_bucket.audit_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enterprise CloudTrail for Global Auditing
resource "aws_cloudtrail" "enterprise_audit" {
  name                          = "bank-enterprise-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  depends_on = [aws_s3_bucket_public_access_block.audit_logs]
}

output "audit_bucket" {
  value = aws_s3_bucket.audit_logs.id
}