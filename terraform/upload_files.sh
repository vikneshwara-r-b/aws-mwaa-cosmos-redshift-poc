#!/bin/bash

# Script to manually upload DAGs and configuration files to S3
# This can be used independently of Terraform for quick updates

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MWAA Files Upload Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if terraform output is available
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed or not in PATH${NC}"
    exit 1
fi

# Get bucket name from Terraform output
echo -e "${BLUE}Getting S3 bucket name from Terraform...${NC}"
BUCKET_NAME=$(terraform output -raw mwaa_s3_bucket_name 2>/dev/null)

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}Error: Could not get bucket name from Terraform output${NC}"
    echo -e "${RED}Please run 'terraform apply' first${NC}"
    exit 1
fi

echo -e "${GREEN}Bucket name: $BUCKET_NAME${NC}"
echo ""

# Upload requirements.txt
echo -e "${BLUE}Uploading requirements.txt...${NC}"
aws s3 cp ../mwaa_config_scripts/requirements.txt s3://${BUCKET_NAME}/requirements.txt
echo -e "${GREEN}✓ requirements.txt uploaded${NC}"
echo ""

# Upload startup script
echo -e "${BLUE}Uploading startup script...${NC}"
aws s3 cp ../mwaa_config_scripts/startup_script.sh s3://${BUCKET_NAME}/startup.sh
echo -e "${GREEN}✓ startup.sh uploaded${NC}"
echo ""

# Upload DAGs directory
echo -e "${BLUE}Syncing DAGs directory...${NC}"
aws s3 sync ../dags s3://${BUCKET_NAME}/dags/ \
    --delete \
    --exclude "*.pyc" \
    --exclude "__pycache__/*" \
    --exclude ".DS_Store"
echo -e "${GREEN}✓ DAGs directory synced${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All files uploaded successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Note: MWAA may take a few minutes to pick up the changes${NC}"
