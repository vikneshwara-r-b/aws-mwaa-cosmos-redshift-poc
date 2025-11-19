# AWS MWAA + Redshift Serverless Infrastructure

This Terraform configuration deploys a complete AWS infrastructure for running Apache Airflow with Cosmos and Redshift Serverless for data warehousing.

## Software Versions

| Component | Version | Notes |
|-----------|---------|-------|
| **Airflow (MWAA)** | 2.7.2 | AWS Managed Airflow |
| **astronomer-cosmos** | 1.11.1 | dbt integration for Airflow |
| **dbt-redshift** | 1.7.7 | Data transformation framework |
| **Terraform** | ≥ 1.13.0 | Infrastructure as code |
| **Python** | 3.11 | MWAA runtime |

## Architecture Overview

This setup creates:
- **VPC**: VPC with 2 public subnets and 2 private subnets across 2 AZs
- **NAT Gateway**: Single NAT Gateway for private subnet internet access (cost-optimized)
- **VPC Endpoints**: S3 Gateway Endpoint (AWS manages MWAA service endpoints)
- **MWAA**: Managed Apache Airflow environment (v2.7.2) in private subnets
- **Redshift Serverless**: Namespace and Workgroup for data warehouse
- **S3**: Bucket for DAGs, requirements, and startup scripts
- **IAM**: Roles and policies for secure service integration
- **Security Groups**: Network isolation and controlled access

**Note**: MWAA uses SERVICE mode for endpoint management - AWS automatically creates and manages the required VPC endpoints for Airflow services.

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         AWS Cloud (us-east-1)                               │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                                │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────┐   ┌──────────────────────────────┐   │   │
│  │  │   Public Subnets (2)    │   │   Private Subnets (2)        │   │   │
│  │  │   - 10.0.1.0/24         │   │   - 10.0.10.0/24             │   │   │
│  │  │   - 10.0.2.0/24         │   │   - 10.0.20.0/24             │   │   │
│  │  │                         │   │                              │   │   │
│  │  │  ┌─────────────────┐   │   │   ┌────────────────────┐    │   │   │
│  │  │  │ NAT Gateway     │   │   │   │ MWAA Environment   │    │   │   │
│  │  │  │ (Single EIP)    │   │   │   │  - Airflow 2.7.2   │    │   │   │
│  │  │  └─────────────────┘   │   │   │  - Cosmos 1.11.1   │    │   │   │
│  │  │          │              │   │   │  - mw1.small       │    │   │   │
│  │  │          │              │   │   │  - 1-2 workers     │    │   │   │
│  │  │  ┌───────▼──────┐      │   │   └────────────────────┘    │   │   │
│  │  │  │ Internet     │      │   │            │                 │   │   │
│  │  │  │ Gateway      │      │   │            │                 │   │   │
│  │  │  └──────────────┘      │   │   ┌────────▼───────────┐    │   │   │
│  │  │                         │   │   │ Redshift Serverless│    │   │   │
│  │  └─────────────────────────┘   │   │  - Namespace       │    │   │   │
│  │              │                  │   │  - Workgroup       │    │   │   │
│  │              │                  │   │  - sales_dw DB     │    │   │   │
│  │              │                  │   │  - 8 RPUs          │    │   │   │
│  │              │                  │   └────────────────────┘    │   │   │
│  │              │                  │                              │   │   │
│  │       ┌──────▼──────────┐      │       ┌────────────────┐    │   │   │
│  │       │ S3 VPC Endpoint │◄─────┼───────│ Route Tables   │    │   │   │
│  │       │  (Gateway)      │      │       │  - Public RT   │    │   │   │
│  │       └─────────────────┘      │       │  - Private RT  │    │   │   │
│  │                                 │       └────────────────┘    │   │   │
│  └──────────────────────────────────────────────────────────────┘   │   │
│                                                                       │   │
│  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │                    S3 Bucket (MWAA)                           │   │   │
│  │  - DAGs, requirements.txt, startup.sh                        │   │   │
│  │  - Versioning enabled, AES256 encrypted                      │   │   │
│  └──────────────────────────────────────────────────────────────┘   │   │
│                                                                       │   │
│  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │                   AWS Secrets Manager                         │   │   │
│  │  - Redshift admin credentials                                │   │   │
│  └──────────────────────────────────────────────────────────────┘   │   │
│                                                                       │   │
│  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │                      IAM Roles                                │   │   │
│  │  ┌────────────────────┐     ┌────────────────────────┐      │   │   │
│  │  │ MWAA Execution     │     │ Redshift Serverless    │      │   │   │
│  │  │  - S3 Access       │     │  - S3 Access           │      │   │   │
│  │  │  - CloudWatch Logs │     │                        │      │   │   │
│  │  │  - SQS/KMS         │     │                        │      │   │   │
│  │  │  - Redshift Access │     │                        │      │   │   │
│  │  └────────────────────┘     └────────────────────────┘      │   │   │
│  └──────────────────────────────────────────────────────────────┘   │   │
│                                                                       │   │
│  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │                    Security Groups                            │   │   │
│  │  - MWAA SG: Self-referencing, all egress                     │   │   │
│  │  - Redshift SG: Port 5439 from MWAA, all egress             │   │   │
│  └──────────────────────────────────────────────────────────────┘   │   │
└───────────────────────────────────────────────────────────────────────────┘

Traffic Flow:
─────────────
1. User → Airflow UI (Public webserver via HTTPS)
2. MWAA → S3 (via VPC Endpoint, no internet)
3. MWAA → Redshift (via Security Group rules, port 5439)
4. MWAA → Internet (via NAT Gateway for pip installs, API calls)
5. Redshift → S3 (via VPC Endpoint for COPY/UNLOAD)
```

## Prerequisites

Before deploying, ensure you have:

1. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```

2. **Terraform** v1.13.0 or later
   ```bash
   terraform version
   ```

3. **AWS Credentials** with appropriate permissions:
   - VPC and networking resources
   - MWAA environments
   - Redshift Serverless
   - S3 buckets
   - IAM roles and policies
   - Secrets Manager

4. **Project Files** in parent directory:
   - `dags/` - Your Airflow DAG files
   - `mwaa_config_scripts/requirements.txt` - Python dependencies
   - `mwaa_config_scripts/startup_script.sh` - Environment startup script

## Configuration

### Variables

You can customize the deployment by modifying `terraform.tfvars`:

```hcl
# AWS Configuration
aws_region       = "us-east-1"
environment_name = "sales-dw-poc"

# Network Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

# MWAA Configuration
mwaa_airflow_version   = "2.7.2"
mwaa_environment_class = "mw1.small"
mwaa_max_workers       = 2
mwaa_min_workers       = 1

# Redshift Configuration
redshift_database_name  = "sales_dw"
redshift_admin_username = "admin"
redshift_base_capacity  = 8  # RPUs (128 RPU = 1 node)
```

## Deployment Steps

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads required provider plugins.

### 2. Review the Plan

```bash
terraform plan
```

Review the resources that will be created. You should see approximately 30+ resources.

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 20-30 minutes, mainly due to MWAA environment creation.

### 4. Verify Deployment

Once complete, Terraform will output important information:

```bash
terraform output
```

Key outputs include:
- `mwaa_webserver_url` - Airflow UI URL
- `redshift_workgroup_endpoint` - Redshift connection endpoint
- `mwaa_s3_bucket_name` - S3 bucket for DAGs

## Post-Deployment Configuration

### 1. Access Airflow UI

Get the MWAA webserver URL:
```bash
terraform output mwaa_webserver_url
```

Navigate to this URL and sign in with your AWS credentials.

### 2. Create Redshift Connection in Airflow

In the Airflow UI, create a new connection:

**Connection Details:**
```
Connection Id: redshift_default
Connection Type: Amazon Redshift
Host: <from terraform output: redshift_workgroup_endpoint>
Database: sales_dw
Port: 5439
Login: admin
Password: <retrieve from AWS Secrets Manager>
```

To get the password:
```bash
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw redshift_admin_secret_arn) \
  --query SecretString --output text | jq -r .password
```

### 3. Verify DAGs

Your DAGs should automatically appear in the Airflow UI. The system automatically uploads:
- All files from `../dags/` directory
- `requirements.txt` with astronomer-cosmos
- `startup_script.sh` for dbt installation

## Updating DAGs and Configuration

### Option 1: Using Terraform

Make changes to your DAG files and re-apply:
```bash
terraform apply
```

Terraform will detect changes and re-upload modified files.

### Option 2: Using Upload Script

For quick updates without running full Terraform:
```bash
./upload_files.sh
```

This script:
- Uploads `requirements.txt`
- Uploads `startup_script.sh`
- Syncs the entire `dags/` directory

### Option 3: Manual AWS CLI

```bash
BUCKET=$(terraform output -raw mwaa_s3_bucket_name)
aws s3 sync ../dags s3://${BUCKET}/dags/ --delete
```

## Resource Details

### MWAA Environment
- **Version**: Airflow 2.7.2
- **Size**: mw1.small (1 vCPU, 2GB RAM per worker)
- **Workers**: 1-2 (auto-scaling)
- **Access**: Public webserver
- **Logging**: All logs enabled (INFO level)

### Redshift Serverless
- **Namespace**: Logical grouping for databases
- **Workgroup**: Compute resources (8 RPUs)
- **Database**: sales_dw
- **Access**: VPC-based (from MWAA only)
- **Credentials**: Stored in AWS Secrets Manager

### S3 Bucket
- **Versioning**: Enabled
- **Encryption**: AES256
- **Public Access**: Blocked
- **VPC Endpoint**: Enabled for cost optimization

### Networking
- **VPC**: 10.0.0.0/16
- **Public Subnets**: 2 subnets across 2 AZs
- **Internet Gateway**: For public access
- **S3 VPC Endpoint**: Gateway endpoint (no cost)

## Troubleshooting

### dbt Version Compatibility

**Issue**: DAG fails with "dbt executable not found" or version errors

**Solution**:
1. Verify `startup_script.sh` uses dbt-redshift 1.7.7
2. Ensure astronomer-cosmos 1.11.1 in requirements.txt
3. Check CloudWatch logs for installation errors:
   ```bash
   aws logs tail /aws/mwaa/sales-dw-poc-Worker --follow
   ```

### Cosmos Version Errors

**Issue**: "Unable to run dbt ls" or "--output-keys not recognized"

**Solution**: Older dbt versions (< 1.5.0) don't support required arguments. Use dbt-redshift 1.7.7.

## Common Issues

### MWAA Environment Fails to Create

1. Check CloudWatch logs:
   ```bash
   aws logs tail /aws/mwaa/sales-dw-poc --follow
   ```

2. Common issues:
   - Invalid requirements.txt syntax
   - Startup script errors
   - IAM permissions

### Cannot Connect to Redshift

1. Verify security group rules:
   ```bash
   terraform output redshift_security_group_id
   ```

2. Check Redshift endpoint:
   ```bash
   terraform output redshift_workgroup_endpoint
   ```

3. Test connection from MWAA:
   - Create a test DAG with PostgresOperator
   - Use connection `redshift_default`

### DAGs Not Appearing

1. Check S3 bucket contents:
   ```bash
   aws s3 ls s3://$(terraform output -raw mwaa_s3_bucket_name)/dags/ --recursive
   ```

2. Verify MWAA can access S3:
   - Check IAM role permissions
   - Review MWAA environment logs

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete:
- MWAA environment
- Redshift Serverless (namespace and workgroup)
- S3 bucket (with all DAGs and data)
- VPC and all networking components

Type `yes` when prompted.

## Security Best Practices

1. **Credentials Management**
   - Redshift password stored in Secrets Manager
   - Rotate passwords regularly
   - Use IAM authentication where possible

2. **Network Security**
   - Redshift not publicly accessible
   - Security groups restrict access to MWAA only
   - VPC endpoints for S3 (no internet traversal)

3. **S3 Security**
   - Bucket versioning enabled
   - Server-side encryption enabled
   - Public access blocked
   - Bucket policies restrict access

4. **IAM Security**
   - Least privilege access
   - Separate roles for MWAA and Redshift
   - Service-specific policies

## Support and Documentation

- [AWS MWAA Documentation](https://docs.aws.amazon.com/mwaa/)
- [Redshift Serverless Documentation](https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-workgroup-namespace.html)
- [Astronomer Cosmos Documentation](https://astronomer.github.io/astronomer-cosmos/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)

## File Structure

```
terraform/
├── main.tf                 # Provider configuration
├── versions.tf             # Terraform and provider versions
├── variables.tf            # Input variables
├── terraform.tfvars        # Variable values
├── vpc.tf                  # VPC and networking
├── s3.tf                   # S3 buckets
├── iam.tf                  # IAM roles and policies
├── security_groups.tf      # Security groups
├── redshift.tf             # Redshift Serverless
├── mwaa.tf                 # MWAA environment
├── file_uploads.tf         # Automated file uploads
├── outputs.tf              # Output values
├── upload_files.sh         # Manual upload script
└── README.md               # This file
```

## Version History

- **v1.0.0** - Initial release with MWAA 2.7.2 and Redshift Serverless

## Contributing

This is a POC configuration. For production use:
- Add private subnets and NAT gateways
- Implement VPC peering or Transit Gateway
- Add WAF for webserver protection
- Implement comprehensive monitoring
- Add automated backups
- Use Terraform workspaces for environments
