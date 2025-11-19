provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
