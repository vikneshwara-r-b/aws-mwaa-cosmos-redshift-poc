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

### Local Development

1. **Prerequisites**
   ```bash
   # Install Astronomer CLI
   brew install astro
   
   # Verify installation
   astro version
   ```

2. **Start Local Airflow**
   ```bash
   astro dev start
   ```
   
   This spins up Docker containers for:
   - Postgres (metadata database)
   - Scheduler
   - Webserver (http://localhost:8080)
   - Triggerer

3. **Access Airflow UI**
   - URL: http://localhost:8080
   - Username: `admin`
   - Password: `admin`

### AWS Deployment

For deploying to AWS MWAA, see comprehensive instructions in:
- **[TERRAFORM_SETUP.md](TERRAFORM_SETUP.md)** - Quick deployment guide
- **[terraform/README.md](terraform/README.md)** - Detailed Terraform documentation

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

## Development

### Adding Dependencies

1. Update `requirements.txt` for Airflow packages
2. Update `mwaa_config_scripts/requirements.txt` for MWAA
3. Restart local environment:
   ```bash
   astro dev restart
   ```

### Modifying dbt Models

1. Edit models in `dags/dbt/sales_dw/models/`
2. Test locally:
   ```bash
   cd dags/dbt/sales_dw
   dbt run
   ```
3. Changes are automatically picked up by Cosmos

## Troubleshooting

### dbt Not Found
If you see "dbt executable not found":
- Verify `startup_script.sh` has correct dbt version (1.7.7)
- Check MWAA worker logs in CloudWatch

### Cosmos Version Issues
Ensure astronomer-cosmos 1.11.1 is specified in requirements.txt - older versions may have compatibility issues with dbt 1.7.x

### Connection Issues
Verify Redshift connection in Airflow:
- Connection ID: `redshift_default`
- Type: Amazon Redshift
- Host/Port: From Terraform outputs

## Resources

- [AWS MWAA Documentation](https://docs.aws.amazon.com/mwaa/)
- [Astronomer Cosmos](https://astronomer.github.io/astronomer-cosmos/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Astronomer CLI](https://www.astronomer.io/docs/astro/cli/overview)

## Support

For issues or questions:
1. Check [TERRAFORM_SETUP.md](TERRAFORM_SETUP.md) troubleshooting section
2. Review CloudWatch logs for MWAA
3. Consult AWS MWAA documentation

## License

This is a proof-of-concept project for demonstration purposes.
