variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Environment name used as prefix for all resources"
  type        = string
  default     = "sales-dw-poc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (required for MWAA)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "mwaa_airflow_version" {
  description = "Airflow version for MWAA environment"
  type        = string
  default     = "2.7.2"
}

variable "mwaa_environment_class" {
  description = "MWAA environment class"
  type        = string
  default     = "mw1.small"
}

variable "mwaa_max_workers" {
  description = "Maximum number of workers for MWAA"
  type        = number
  default     = 2
}

variable "mwaa_min_workers" {
  description = "Minimum number of workers for MWAA"
  type        = number
  default     = 1
}

variable "redshift_database_name" {
  description = "Redshift database name"
  type        = string
  default     = "sales_dw"
}

variable "redshift_admin_username" {
  description = "Redshift admin username"
  type        = string
  default     = "admin"
}

variable "redshift_base_capacity" {
  description = "Base capacity for Redshift Serverless in RPUs"
  type        = number
  default     = 8
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "POC"
    ManagedBy   = "Terraform"
    Project     = "SalesDW"
  }
}
