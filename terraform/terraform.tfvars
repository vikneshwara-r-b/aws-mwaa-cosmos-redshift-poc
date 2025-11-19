# AWS Configuration
aws_region       = "us-east-1"
environment_name = "sales-dw-poc"

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# MWAA Configuration
mwaa_airflow_version   = "2.7.2"
mwaa_environment_class = "mw1.small"
mwaa_max_workers       = 2
mwaa_min_workers       = 1

# Redshift Configuration
redshift_database_name  = "sales_dw"
redshift_admin_username = "admin"
redshift_base_capacity  = 8

# Tags
tags = {
  Environment = "POC"
  ManagedBy   = "Terraform"
  Project     = "SalesDW"
}
