# Security Group for MWAA
resource "aws_security_group" "mwaa" {
  name_prefix = "${var.environment_name}-mwaa-sg-"
  description = "Security group for MWAA environment"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment_name}-mwaa-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Self-referencing rule for MWAA (required for internal communication)
resource "aws_security_group_rule" "mwaa_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.mwaa.id
  self              = true
  description       = "Allow all traffic from self"
}

# Egress rule for MWAA to access internet
resource "aws_security_group_rule" "mwaa_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mwaa.id
  description       = "Allow all outbound traffic"
}

# Security Group for Redshift Serverless
resource "aws_security_group" "redshift" {
  name_prefix = "${var.environment_name}-redshift-sg-"
  description = "Security group for Redshift Serverless"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment_name}-redshift-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress rule to allow MWAA to connect to Redshift
resource "aws_security_group_rule" "redshift_from_mwaa" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mwaa.id
  security_group_id        = aws_security_group.redshift.id
  description              = "Allow Redshift access from MWAA"
}

# Egress rule for Redshift
resource "aws_security_group_rule" "redshift_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redshift.id
  description       = "Allow all outbound traffic"
}
