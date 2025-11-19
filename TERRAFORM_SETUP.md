# Terraform Infrastructure Setup Guide

## Software Versions

| Component | Version |
|-----------|---------|
| **Airflow (MWAA)** | 2.7.2 |
| **astronomer-cosmos** | 1.11.1 |
| **dbt-redshift** | 1.7.7 |
| **Terraform** | ≥ 1.13.0 |
| **Python** | 3.11 |

## Overview

Complete Terraform infrastructure has been created in the `terraform/` directory for deploying:
- AWS MWAA (Managed Airflow) v2.7.2
- Redshift Serverless (Namespace + Workgroup)
- VPC with public and private subnets
- S3 bucket for DAGs
- IAM roles and security groups

## Quick Start

### 1. Navigate to Terraform Directory
```bash
cd terraform
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review Resources
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~20-30 minutes.

## What Gets Created

### Infrastructure Resources (~35+ resources)
- **VPC**: 1 VPC with 2 public subnets and 2 private subnets across 2 AZs
- **Networking**: Internet Gateway, NAT Gateway, Route Tables, S3 VPC Endpoint
- **MWAA**: Airflow 2.7.2 environment (mw1.small) in private subnets
- **Redshift**: Serverless namespace + workgroup (8 RPUs)
- **S3**: Bucket with versioning and encryption
- **IAM**: 2 roles (MWAA execution, Redshift) with policies
- **Security Groups**: 2 groups (MWAA, Redshift) with rules
- **Secrets Manager**: Redshift admin password storage
- **NAT Gateway**: Single NAT Gateway for cost-optimized internet access

### Automated File Uploads
The infrastructure automatically uploads:
- `dags/` directory → S3 bucket
- `mwaa_config_scripts/requirements.txt` → S3 bucket
- `mwaa_config_scripts/startup_script.sh` → S3 bucket

## Configuration Files Created

```
terraform/
├── main.tf                 # Provider configuration
├── versions.tf             # Terraform 1.13.0+ compatible
├── variables.tf            # All configurable parameters
├── terraform.tfvars        # Your environment values
├── vpc.tf                  # VPC and networking
├── s3.tf                   # S3 buckets
├── iam.tf                  # IAM roles and policies
├── security_groups.tf      # Security groups
├── redshift.tf             # Redshift Serverless
├── mwaa.tf                 # MWAA environment
├── file_uploads.tf         # Automated file uploads
├── outputs.tf              # Output values
├── upload_files.sh         # Manual upload script (executable)
├── .gitignore              # Terraform-specific ignores
└── README.md               # Detailed documentation
```

## Key Configuration (terraform.tfvars)

```hcl
aws_region              = "us-east-1"
environment_name        = "sales-dw-poc"
vpc_cidr                = "10.0.0.0/16"
mwaa_airflow_version    = "2.7.2"
mwaa_environment_class  = "mw1.small"
redshift_database_name  = "sales_dw"
redshift_base_capacity  = 8
```

## After Deployment

### Get Important Information
```bash
# View all outputs
terraform output

# Get MWAA webserver URL
terraform output mwaa_webserver_url

# Get Redshift endpoint
terraform output redshift_workgroup_endpoint

# Get S3 bucket name
terraform output mwaa_s3_bucket_name

# Get Redshift password
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw redshift_admin_secret_arn) \
  --query SecretString --output text | jq -r .password
```

### Access Airflow UI
1. Get the webserver URL from outputs
2. Open in browser
3. Sign in with AWS credentials

### Configure Redshift Connection in Airflow
In Airflow UI, create connection:
- **Connection Id**: `redshift_default`
- **Connection Type**: Amazon Redshift
- **Host**: (from terraform output)
- **Database**: `sales_dw`
- **Port**: `5439`
- **Login**: `admin`
- **Password**: (from Secrets Manager)

## Updating DAGs

### Method 1: Re-run Terraform
```bash
terraform apply
```
Automatically detects and uploads changed files.

### Method 2: Upload Script
```bash
./upload_files.sh
```
Quick manual upload without full Terraform run.

### Method 3: Direct AWS CLI
```bash
BUCKET=$(terraform output -raw mwaa_s3_bucket_name)
aws s3 sync ../dags s3://${BUCKET}/dags/ --delete
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This permanently deletes all infrastructure and data.

## Troubleshooting

### Issue: terraform init fails
**Solution**: Check Terraform version (requires 1.13.0+)
```bash
terraform version
```

### Issue: AWS credentials not found
**Solution**: Configure AWS CLI
```bash
aws configure
```

### Issue: MWAA environment creation fails
**Solution**: Check CloudWatch logs
```bash
aws logs tail /aws/mwaa/sales-dw-poc --follow
```

### Issue: DAGs not appearing
**Solution**: Check S3 bucket contents
```bash
aws s3 ls s3://$(terraform output -raw mwaa_s3_bucket_name)/dags/ --recursive
```

## Next Steps

1. ✅ Deploy infrastructure with `terraform apply`
2. ✅ Access Airflow UI
3. ✅ Create Redshift connection in Airflow
4. ✅ Verify DAGs are loaded
5. ✅ Run your first DAG
6. ✅ Monitor in CloudWatch and Airflow UI

## Documentation

- Full details: `terraform/README.md`
- AWS MWAA: https://docs.aws.amazon.com/mwaa/
- Redshift Serverless: https://docs.aws.amazon.com/redshift/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/

## Security Features

✅ VPC isolation
✅ Security groups (least privilege)
✅ S3 encryption (AES256)
✅ Secrets Manager for passwords
✅ IAM roles (least privilege)
✅ S3 public access blocked
✅ VPC endpoint for S3
✅ CloudWatch logging enabled

---

**Infrastructure Version**: 1.0.0  
**Terraform Version**: >= 1.13.0  
**AWS Provider**: ~> 5.0
