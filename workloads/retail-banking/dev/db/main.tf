
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
  region  = var.aws_region
  profile = "retailprod"
}

# Private subnet group spanning two Availability Zones
resource "aws_db_subnet_group" "retail" {
  name        = "retail-banking-dev-db-subnets"
  description = "Private subnets for Retail Banking Dev PostgreSQL"

  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = "retail-banking-dev-db-subnets"
    Environment = "dev"
    Project     = "retail-banking"
  }
}

# Allow PostgreSQL connections only from the ECS application tier
resource "aws_security_group" "postgres" {
  name        = "retail-banking-dev-postgres-sg"
  description = "Allow PostgreSQL only from ECS application tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from ECS application tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  tags = {
    Name        = "retail-banking-dev-postgres-sg"
    Environment = "dev"
    Project     = "retail-banking"
  }
}

# PostgreSQL database
resource "aws_db_instance" "retail" {
  identifier = "retail-banking-dev-postgres"

  engine         = "postgres"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.retail.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  publicly_accessible = false
  multi_az            = false

  # RDS generates and manages the master password in Secrets Manager.
  manage_master_user_password = true

  backup_retention_period = 7
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true
  apply_immediately           = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "retail-banking-dev-postgres"
    Environment = "dev"
    Project     = "retail-banking"
  }

  depends_on = [
    aws_db_subnet_group.retail,
    aws_security_group.postgres
  ]
}
