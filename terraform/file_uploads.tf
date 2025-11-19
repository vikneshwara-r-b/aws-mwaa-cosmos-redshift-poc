# Upload requirements.txt to S3
resource "aws_s3_object" "requirements" {
  bucket = aws_s3_bucket.mwaa.id
  key    = "requirements.txt"
  source = "../mwaa_config_scripts/requirements.txt"
  etag   = filemd5("../mwaa_config_scripts/requirements.txt")

  tags = {
    Name = "MWAA Requirements File"
  }
}

# Upload startup script to S3
resource "aws_s3_object" "startup_script" {
  bucket = aws_s3_bucket.mwaa.id
  key    = "startup.sh"
  source = "../mwaa_config_scripts/startup_script.sh"
  etag   = filemd5("../mwaa_config_scripts/startup_script.sh")

  tags = {
    Name = "MWAA Startup Script"
  }
}

# Upload DAGs directory to S3
resource "null_resource" "upload_dags" {
  triggers = {
    # Trigger re-upload if any file in dags directory changes
    dags_hash = sha256(join("", [for f in fileset("../dags", "**") : filesha256("../dags/${f}")]))
  }

  provisioner "local-exec" {
    command = "aws s3 sync ../dags s3://${aws_s3_bucket.mwaa.id}/dags/ --delete --exclude '*.pyc' --exclude '__pycache__/*' --exclude '.DS_Store'"
  }

  depends_on = [
    aws_s3_bucket.mwaa,
    aws_s3_bucket_versioning.mwaa
  ]
}
