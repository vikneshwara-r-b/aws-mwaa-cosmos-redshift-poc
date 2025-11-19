# Generate random password for Redshift admin
resource "random_password" "redshift_admin" {
  length  = 16
  special = true
}

# Store the password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "redshift_admin" {
  name_prefix = "${var.environment_name}-redshift-admin-"
  description = "Redshift admin password for ${var.environment_name}"

  tags = {
    Name = "${var.environment_name}-redshift-admin-secret"
  }
}

resource "aws_secretsmanager_secret_version" "redshift_admin" {
  secret_id = aws_secretsmanager_secret.redshift_admin.id
  secret_string = jsonencode({
    username = var.redshift_admin_username
    password = random_password.redshift_admin.result
  })
}

# Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "this" {
  namespace_name = "${var.environment_name}-namespace"

  admin_username = var.redshift_admin_username
  admin_user_password = random_password.redshift_admin.result
  
  db_name = var.redshift_database_name
  
  iam_roles = [aws_iam_role.redshift_serverless.arn]

  tags = {
    Name = "${var.environment_name}-namespace"
  }
}

# Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "this" {
  namespace_name = aws_redshiftserverless_namespace.this.namespace_name
  workgroup_name = "${var.environment_name}-workgroup"

  base_capacity      = var.redshift_base_capacity
  publicly_accessible = false

  subnet_ids         = aws_subnet.public[*].id
  security_group_ids = [aws_security_group.redshift.id]

  tags = {
    Name = "${var.environment_name}-workgroup"
  }
}
