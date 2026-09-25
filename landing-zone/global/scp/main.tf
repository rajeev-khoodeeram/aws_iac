#############################################################################
# AWS Banking Landing Zone - Service Control Policies
# Author: Rajeev Khoodeeram
#
# Purpose:
#   Apply organization-level governance guardrails to AWS OUs.
#############################################################################

# ---------------------------------------------------------------------------
# 1. Deny Unapproved AWS Regions
# ---------------------------------------------------------------------------

resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "Deny-Unapproved-Regions"
  description = "Restrict AWS resource creation to approved regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/deny-unapproved-regions.json")
}

resource "aws_organizations_policy_attachment" "deny_unapproved_regions_workloads" {
  policy_id = aws_organizations_policy.deny_unapproved_regions.id
  target_id = var.workloads_ou_id
}


# ---------------------------------------------------------------------------
# 2. Prevent Accounts Leaving AWS Organization
# ---------------------------------------------------------------------------

resource "aws_organizations_policy" "deny_leaving_organization" {
  name        = "Deny-Leaving-Organization"
  description = "Prevent member accounts from leaving the AWS Organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/deny-leaving-organization.json")
}

resource "aws_organizations_policy_attachment" "deny_leaving_organization_workloads" {
  policy_id = aws_organizations_policy.deny_leaving_organization.id
  target_id = var.workloads_ou_id
}


# ---------------------------------------------------------------------------
# 3. Protect Security Services
# ---------------------------------------------------------------------------

resource "aws_organizations_policy" "deny_security_service_changes" {
  name        = "Deny-Security-Service-Changes"
  description = "Prevent workloads from disabling AWS security services"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/deny-security-service-changes.json")
}

resource "aws_organizations_policy_attachment" "deny_security_service_changes_workloads" {
  policy_id = aws_organizations_policy.deny_security_service_changes.id
  target_id = var.workloads_ou_id
}


# ---------------------------------------------------------------------------
# 4. Protect CloudTrail
# ---------------------------------------------------------------------------

resource "aws_organizations_policy" "deny_cloudtrail_changes" {
  name        = "Deny-CloudTrail-Changes"
  description = "Prevent workloads from disabling or modifying CloudTrail"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/deny-cloudtrail-changes.json")
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_changes_workloads" {
  policy_id = aws_organizations_policy.deny_cloudtrail_changes.id
  target_id = var.workloads_ou_id
}