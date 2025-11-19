# IAM Role for MWAA
resource "aws_iam_role" "mwaa_execution" {
  name = "${var.environment_name}-mwaa-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "airflow-env.amazonaws.com",
            "airflow.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment_name}-mwaa-execution-role"
  }
}

# IAM Policy for MWAA to access S3
resource "aws_iam_role_policy" "mwaa_s3_policy" {
  name = "${var.environment_name}-mwaa-s3-policy"
  role = aws_iam_role.mwaa_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:PutObject*",
          "s3:DeleteObject*"
        ]
        Resource = [
          aws_s3_bucket.mwaa.arn,
          "${aws_s3_bucket.mwaa.arn}/*"
        ]
      }
    ]
  })
}

# IAM Policy for MWAA to publish CloudWatch logs
resource "aws_iam_role_policy" "mwaa_cloudwatch_policy" {
  name = "${var.environment_name}-mwaa-cloudwatch-policy"
  role = aws_iam_role.mwaa_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.environment_name}-*"
      }
    ]
  })
}

# IAM Policy for MWAA to access Redshift
resource "aws_iam_role_policy" "mwaa_redshift_policy" {
  name = "${var.environment_name}-mwaa-redshift-policy"
  role = aws_iam_role.mwaa_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "redshift-serverless:GetNamespace",
          "redshift-serverless:GetWorkgroup",
          "redshift-serverless:GetCredentials",
          "redshift-data:ExecuteStatement",
          "redshift-data:DescribeStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:ListDatabases",
          "redshift-data:ListSchemas",
          "redshift-data:ListTables"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for MWAA base execution (SQS, Metrics, KMS)
resource "aws_iam_role_policy" "mwaa_base_execution_policy" {
  name = "${var.environment_name}-mwaa-base-execution-policy"
  role = aws_iam_role.mwaa_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "airflow:PublishMetrics"
        Resource = "arn:aws:airflow:${var.aws_region}:${data.aws_caller_identity.current.account_id}:environment/${var.environment_name}"
      },
      {
        Effect = "Allow"
        Action = "cloudwatch:PutMetricData"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ]
        Resource = "arn:aws:sqs:${var.aws_region}:*:airflow-celery-*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt"
        ]
        NotResource = "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
        Condition = {
          StringLike = {
            "kms:ViaService" = [
              "sqs.${var.aws_region}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# IAM Role for Redshift Serverless
resource "aws_iam_role" "redshift_serverless" {
  name = "${var.environment_name}-redshift-serverless-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment_name}-redshift-serverless-role"
  }
}

# IAM Policy for Redshift to access S3 (for COPY/UNLOAD commands)
resource "aws_iam_role_policy" "redshift_s3_policy" {
  name = "${var.environment_name}-redshift-s3-policy"
  role = aws_iam_role.redshift_serverless.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.mwaa.arn,
          "${aws_s3_bucket.mwaa.arn}/*"
        ]
      }
    ]
  })
}
