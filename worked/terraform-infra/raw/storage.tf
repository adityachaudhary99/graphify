resource "aws_s3_bucket" "app" {
  bucket = "${var.environment}-app-data-${random_pet.suffix.id}"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-logs-${random_pet.suffix.id}"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.environment}-backups-${random_pet.suffix.id}"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "cross-region-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.dr_backups.arn
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket" "dr_backups" {
  provider = aws.dr
  bucket   = "${var.environment}-dr-backups-${random_pet.suffix.id}"

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "replication" {
  name = "${var.environment}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "replication" {
  name = "${var.environment}-s3-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*",
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.dr_backups.arn,
          "${aws_s3_bucket.dr_backups.arn}/*",
        ]
      },
    ]
  })
}
