# New-Item -ItemType Directory -Path bank-aws-terraform

# Organization & Governance (Equivalent to Management Groups, Policies, RBAC)
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/global/organizations -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/global/scp -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/global/iam-baseline -Force

# Core Platform Landing Zones
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/platform/identity -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/platform/networking -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/platform/security -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/platform/logging -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/platform/shared-services -Force

# Landing Zones / Environments
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/landingzones/retail-banking-prod -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/landingzones/retail-banking-nonprod -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/landingzones/payments-prod -Force
New-Item -ItemType Directory -Path bank-aws-terraform/landing-zone/landingzones/fraud-detection-prod -Force

# Workloads (Retail Banking, Payments, Fraud Detection)
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/frontend/dev -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/frontend/test -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/frontend/prod -Force

New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/api/dev -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/api/test -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/api/prod -Force

New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/database/dev -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/database/test -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/retail-banking/database/prod -Force

New-Item -ItemType Directory -Path bank-aws-terraform/workloads/payments/api -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/payments/database -Force

New-Item -ItemType Directory -Path bank-aws-terraform/workloads/fraud-detection/api -Force
New-Item -ItemType Directory -Path bank-aws-terraform/workloads/fraud-detection/ml-engine -Force

# Reusable Terraform Modules (Equivalent to your Azure modules)
New-Item -ItemType Directory -Path bank-aws-terraform/modules/eks -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/vpc -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/rds -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/kms-secrets -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/vpc-endpoints -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/ecs-fargate -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/cloudwatch -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/iam-roles -Force
New-Item -ItemType Directory -Path bank-aws-terraform/modules/scp-policies -Force

# CI/CD Pipelines
New-Item -ItemType Directory -Path bank-aws-terraform/pipelines/aws-codecatalyst -Force
New-Item -ItemType Directory -Path bank-aws-terraform/pipelines/github-actions -Force