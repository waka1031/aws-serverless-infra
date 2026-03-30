locals {
  name_prefix = "${var.project}-${var.environment}"
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-aurora-subnet-group"
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-aurora-sg"
  description = "Security group for Aurora Serverless v2 cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-aurora-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgresql" {
  security_group_id = aws_security_group.this.id
  description       = "Allow PostgreSQL from VPC"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_ipv4         = var.vpc_cidr

  tags = {
    Name = "${local.name_prefix}-aurora-sg-ingress"
  }
}

################################################################################
# Secrets Manager (Master Credentials)
################################################################################

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "master" {
  name                    = "${local.name_prefix}-aurora-master-credentials"
  description             = "Master credentials for Aurora Serverless v2 cluster"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.name_prefix}-aurora-master-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id = aws_secretsmanager_secret.master.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

################################################################################
# Aurora Serverless v2 Cluster
################################################################################

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.name_prefix}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  enable_http_endpoint                = true
  storage_encrypted                   = true
  copy_tags_to_snapshot               = true
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_database_authentication_enabled = true

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = {
    Name = "${local.name_prefix}-aurora-cluster"
  }
}

################################################################################
# Aurora Instance (Writer)
################################################################################

resource "aws_rds_cluster_instance" "writer" {
  identifier                 = "${local.name_prefix}-aurora-instance-1"
  cluster_identifier         = aws_rds_cluster.this.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.this.engine
  engine_version             = aws_rds_cluster.this.engine_version
  auto_minor_version_upgrade = true

  tags = {
    Name = "${local.name_prefix}-aurora-instance-1"
  }
}

################################################################################
# IAM Policy (Lambda -> RDS Data API + Secrets Manager)
################################################################################

resource "aws_iam_policy" "lambda_rds_data_api" {
  name        = "${local.name_prefix}-lambda-rds-data-api"
  description = "Allow Lambda to access Aurora via RDS Data API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = aws_rds_cluster.this.arn
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.master.arn
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-lambda-rds-data-api"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_rds_data_api" {
  role       = var.lambda_role_name
  policy_arn = aws_iam_policy.lambda_rds_data_api.arn
}
