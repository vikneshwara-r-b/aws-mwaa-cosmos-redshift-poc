# MWAA Environment
resource "aws_mwaa_environment" "this" {
  name = "${var.environment_name}-mwaa-instance"

  airflow_version       = var.mwaa_airflow_version
  environment_class     = var.mwaa_environment_class
  execution_role_arn    = aws_iam_role.mwaa_execution.arn
  
  source_bucket_arn     = aws_s3_bucket.mwaa.arn
  dag_s3_path           = "dags"
  requirements_s3_path  = "requirements.txt"
  startup_script_s3_path = "startup.sh"

  # Network configuration (MWAA requires private subnets)
  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = aws_subnet.private[*].id
  }

  # Logging configuration
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  # Worker configuration
  max_workers = var.mwaa_max_workers
  min_workers = var.mwaa_min_workers

  # Airflow configuration options
  airflow_configuration_options = {
    "core.default_timezone" = "UTC"
    "core.load_examples"    = "False"
  }

  # Web server access mode
  webserver_access_mode = "PUBLIC_ONLY"

  tags = {
    Name = "${var.environment_name}-mwaa"
  }

  depends_on = [
    aws_s3_object.requirements,
    aws_s3_object.startup_script,
    null_resource.upload_dags,
    aws_nat_gateway.main
  ]
}
