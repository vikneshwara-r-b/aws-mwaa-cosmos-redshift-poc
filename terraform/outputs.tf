# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (used by MWAA)"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "vpc_endpoint_s3_id" {
  description = "ID of the S3 VPC Endpoint (Gateway)"
  value       = aws_vpc_endpoint.s3.id
}

# S3 Outputs
output "mwaa_s3_bucket_name" {
  description = "Name of the S3 bucket for MWAA"
  value       = aws_s3_bucket.mwaa.id
}

output "mwaa_s3_bucket_arn" {
  description = "ARN of the S3 bucket for MWAA"
  value       = aws_s3_bucket.mwaa.arn
}

# MWAA Outputs
output "mwaa_environment_name" {
  description = "Name of the MWAA environment"
  value       = aws_mwaa_environment.this.name
}

output "mwaa_webserver_url" {
  description = "Webserver URL for the MWAA environment"
  value       = aws_mwaa_environment.this.webserver_url
}

output "mwaa_arn" {
  description = "ARN of the MWAA environment"
  value       = aws_mwaa_environment.this.arn
}

output "mwaa_execution_role_arn" {
  description = "ARN of the MWAA execution role"
  value       = aws_iam_role.mwaa_execution.arn
}

# Redshift Outputs
output "redshift_namespace_id" {
  description = "ID of the Redshift Serverless namespace"
  value       = aws_redshiftserverless_namespace.this.namespace_id
}

output "redshift_namespace_arn" {
  description = "ARN of the Redshift Serverless namespace"
  value       = aws_redshiftserverless_namespace.this.arn
}

output "redshift_workgroup_id" {
  description = "ID of the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.this.workgroup_id
}

output "redshift_workgroup_arn" {
  description = "ARN of the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.this.arn
}

output "redshift_workgroup_endpoint" {
  description = "Endpoint for the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.this.endpoint[0].address
}

output "redshift_workgroup_port" {
  description = "Port for the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.this.endpoint[0].port
}

output "redshift_database_name" {
  description = "Name of the Redshift database"
  value       = var.redshift_database_name
}

output "redshift_admin_username" {
  description = "Redshift admin username"
  value       = var.redshift_admin_username
  sensitive   = true
}

output "redshift_admin_secret_arn" {
  description = "ARN of the secret storing Redshift admin credentials"
  value       = aws_secretsmanager_secret.redshift_admin.arn
}

# Security Group Outputs
output "mwaa_security_group_id" {
  description = "ID of the MWAA security group"
  value       = aws_security_group.mwaa.id
}

output "redshift_security_group_id" {
  description = "ID of the Redshift security group"
  value       = aws_security_group.redshift.id
}

# Connection Information for Airflow
output "redshift_connection_info" {
  description = "Information needed to create Airflow connection to Redshift"
  value = {
    host     = aws_redshiftserverless_workgroup.this.endpoint[0].address
    port     = aws_redshiftserverless_workgroup.this.endpoint[0].port
    database = var.redshift_database_name
    username = var.redshift_admin_username
    secret_arn = aws_secretsmanager_secret.redshift_admin.arn
  }
  sensitive = true
}
