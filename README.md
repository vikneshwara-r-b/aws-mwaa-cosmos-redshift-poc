# AWS MWAA Cosmos Redshift POC

A proof-of-concept project demonstrating integration between AWS Managed Apache Airflow (MWAA), Astronomer Cosmos, dbt, and Redshift Serverless for data warehousing.

## Overview

This project showcases a modern data pipeline architecture using:
- **AWS MWAA** for orchestration with Apache Airflow
- **Astronomer Cosmos** for seamless dbt integration
- **dbt** for data transformations
- **Redshift Serverless** as the data warehouse
- **Terraform** for infrastructure as code

## Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **AWS MWAA** | Airflow 2.7.2 | Managed workflow orchestration |
| **astronomer-cosmos** | 1.11.1 | dbt + Airflow integration |
| **dbt-redshift** | 1.7.7 | Data transformation framework |
| **Redshift Serverless** | Latest | Data warehouse |
| **Python** | 3.11 | Runtime environment |
| **Terraform** | ≥ 1.13.0 | Infrastructure provisioning |

## Project Structure

```
aws-mwaa-cosmos-redshift-poc/
├── dags/                          # Airflow DAG definitions
│   ├── sales_data_ingest_and_transform.py
│   └── dbt/sales_dw/             # dbt project
│       ├── models/               # dbt models (staging, dimensions, facts)
│       └── seeds/                # Sample data
├── mwaa_config_scripts/          # MWAA configuration
│   ├── requirements.txt          # Python dependencies
│   └── startup_script.sh         # Environment setup script
├── terraform/                    # Infrastructure as code
│   ├── *.tf                     # Terraform configurations
│   └── README.md                # Detailed Terraform docs
├── redshift_scripts/            # SQL scripts
└── README.md                    # This file
```

## Quick Start

This project is designed for **AWS MWAA deployment**. Local Astronomer files (Dockerfile, packages.txt) have been removed as this is an AWS-focused implementation.

### Deploy to AWS MWAA

For deploying to AWS MWAA, see comprehensive instructions in:
- **[TERRAFORM_SETUP.md](TERRAFORM_SETUP.md)** - Quick deployment guide
- **[terraform/README.md](terraform/README.md)** - Detailed Terraform documentation

### Deployment Steps Summary

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Deploy infrastructure with Terraform**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Access MWAA Airflow UI**
   - Get URL: `terraform output mwaa_webserver_url`
   - Sign in with AWS credentials

4. **Configure Redshift connection** in Airflow UI (see Terraform docs)

## Key Features

- ✅ **Astronomer Cosmos Integration** - Native dbt support in Airflow
- ✅ **Redshift Serverless** - Scalable data warehouse
- ✅ **Infrastructure as Code** - Complete Terraform setup
- ✅ **Automated Deployments** - CI/CD ready
- ✅ **Version Pinning** - Reproducible environments

## DAGs

### sales_data_ingest_and_transform
Main pipeline that:
1. Loads seed data into Redshift
2. Runs dbt transformations (staging → dimensions → facts)
3. Tests data quality

## Development Workflow

This project is optimized for **AWS MWAA deployment only**. Local Astronomer files have been removed.

### Updating Python Dependencies

To add or update Python packages in MWAA:

1. Edit `mwaa_config_scripts/requirements.txt`
2. Deploy to AWS:
   ```bash
   cd terraform
   ./upload_files.sh
   ```
3. Update MWAA environment via AWS Console or:
   ```bash
   aws mwaa update-environment \
     --name sales-dw-poc \
     --requirements-s3-path requirements.txt \
     --region us-east-1
   ```
4. Wait 20-30 minutes for MWAA environment update

### Updating System Dependencies

To modify dbt or other system-level packages:

1. Edit `mwaa_config_scripts/startup_script.sh`
2. Deploy and update MWAA (same process as above with `--startup-script-s3-path`)

### Modifying DAGs or dbt Models

1. Edit files in `dags/` directory
2. Deploy changes:
   ```bash
   cd terraform
   ./upload_files.sh  # Syncs DAGs to S3
   ```
3. MWAA automatically picks up changes within minutes
4. Verify in Airflow UI

**Note**: For dbt model testing, you can set up a local dbt environment separately, but it requires configuring Redshift connection locally (outside scope of this project).

## Troubleshooting

### dbt Not Found
If you see "dbt executable not found" in AWS MWAA:
- Verify `mwaa_config_scripts/startup_script.sh` has dbt-redshift 1.7.7
- Check MWAA worker logs in CloudWatch:
  ```bash
  aws logs tail /aws/mwaa/sales-dw-poc-Worker --follow
  ```
- Ensure MWAA environment has been updated after changing startup script

### Cosmos Version Issues
Ensure astronomer-cosmos 1.11.1 is specified in `mwaa_config_scripts/requirements.txt` - older versions may have compatibility issues with dbt 1.7.x

### Connection Issues
Verify Redshift connection in Airflow UI:
- **Connection ID**: `redshift_default`
- **Type**: Amazon Redshift
- **Host/Port**: From Terraform outputs
- Get credentials from AWS Secrets Manager

### DAG Import Errors
If DAGs fail to load:
1. Check S3 bucket has correct files
2. Verify MWAA can access S3 (check IAM permissions)
3. Review DAG processing logs in CloudWatch

## Resources

- [AWS MWAA Documentation](https://docs.aws.amazon.com/mwaa/)
- [Astronomer Cosmos Documentation](https://astronomer.github.io/astronomer-cosmos/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Redshift Serverless Documentation](https://docs.aws.amazon.com/redshift/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)

## Support

For issues or questions:
1. Check [TERRAFORM_SETUP.md](TERRAFORM_SETUP.md) troubleshooting section
2. Review CloudWatch logs for MWAA environment
3. Consult [terraform/README.md](terraform/README.md) for detailed infrastructure docs
4. Check AWS MWAA documentation

## License

This is a proof-of-concept project for demonstration purposes.
