data "aws_caller_identity" "current" {}


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

       configuration_aliases = [
        aws.management
      ]
    }
  }
}

resource "aws_s3_bucket" "audit_logs" {
  bucket        = "bank-core-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true // if false, the bucket cannot be deleted if it contains objects - this is practically a safeguard to prevent accidental deletion of audit logs
  //I am turning it ON to avoid surprise charges !!
  // or we can use aws s3 rm.....command

  tags = {
    Name        = "bank-core-audit-logs"
    Environment = "Production"
    Purpose     = "Centralized CloudTrail Logs"
    Compliance  = "PCI-DSS"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_ownership_controls" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ==============================================================================
# 4.2 - CloudTrail S3 Bucket Policy
# ==============================================================================

resource "aws_s3_bucket_policy" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit_logs.arn

        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${var.management_account_id}:trail/bank-core-organization-trail"
          }
        }
      },

      {
        Sid    = "AWSCloudTrailWriteManagementAccount"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${var.management_account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${var.management_account_id}:trail/bank-core-organization-trail"
          }
        }
      },

      {
        Sid    = "AWSCloudTrailOrganizationWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${var.organization_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${var.management_account_id}:trail/bank-core-organization-trail"
          }
        }
      }
    ]
  })
}

# ==============================================================================
# 4.3 - Create Organization Trail
# Objective :   Create a CloudTrail trail that captures logs for the entire AWS organization
# ==============================================================================
resource "aws_cloudtrail" "organization" {

  provider = aws.management
  name                          = "bank-core-organization-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail        = true

  enable_log_file_validation = true

  depends_on = [
    aws_s3_bucket_policy.audit_logs
  ]

  tags = {
    Name        = "bank-core-organization-trail"
    Environment = "Production"
    Purpose     = "Organization-wide AWS Audit Logging"
    Compliance  = "PCI-DSS"
    ManagedBy   = "Terraform"
  }
}