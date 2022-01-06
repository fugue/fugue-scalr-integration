/*
This is a Terraform file to stand up an AWS S3 bucket and logging bucket
*/

// Setting up the demos3 bucket

#Adding the demos3 bucket
resource "aws_s3_bucket" "demos3" {
  bucket = "my-scalr-fugue-test-bucket-27311812"
  acl    = var.acl_value

  #FG_R00274
  logging {
    target_bucket = aws_s3_bucket.logbucket.id
    target_prefix = "log/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        #Un-comment below to satisfy FG_R00099
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    #Un-comment below to satisfy FG_R00101
    enabled = true
    #enabled = false
  }

  lifecycle_rule {
    prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

#Blocking public access for my S3 bucket
resource "aws_s3_bucket_public_access_block" "private12345" {
  # Un-comment below to satisfy FG_R00229
  bucket                  = aws_s3_bucket.demos3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Setting up a bucket policy for my demos3 bucket
resource "aws_s3_bucket_policy" "b" {
  #Un-comment below to satisfy FG_R00100
  bucket = aws_s3_bucket.demos3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.demos3.arn,
          "${aws_s3_bucket.demos3.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

// Setting up my logging bucket for my demos3 bucket

#Logging bucket for my demos3 bucket
resource "aws_s3_bucket" "logbucket" {
  bucket = "my-log-bucket-for-demos3-18122617"
  acl    = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        #Un-comment below to satisfy FG_R00099
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    #Un-comment below to satisfy FG_R00101
    enabled = true
    #enabled = false
  }

  lifecycle_rule {
    prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

#Setting up a bucket policy for my logbucket
resource "aws_s3_bucket_policy" "b1" {
  #Un-comment below to satisfy FG_R00100
  bucket = aws_s3_bucket.logbucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logbucket.arn,
          "${aws_s3_bucket.logbucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

#Blocking public access for my logging bucket
resource "aws_s3_bucket_public_access_block" "private23456" {
  # Un-comment below to satisfy FG_R00229
  bucket                  = aws_s3_bucket.logbucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Setting up my kms key

#Setting a kms key for my S3 bucket
resource "aws_kms_key" "mykey" {
  #Un-comment below to satisfy FG_R00036
  enable_key_rotation = true
}
