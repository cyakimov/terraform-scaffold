# This only handles redirects for http://domain -> http://www.domain
# Need cloudfront support in terraform to handle ssl redirect
resource "aws_s3_bucket" "root-domain-redirect" {
  bucket = "${var.domain}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "www.${var.domain}"
  }

  tags {
    Name = "${var.name_prefix}root-domain-redirect"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.name_prefix}backup"
  acl = "private"

  tags {
    Name = "${var.name_prefix}backup"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.name_prefix}logs"
  force_destroy = true
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.name_prefix}logs"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.name_prefix}logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "cdn" {
  bucket = "cdn.${var.domain}"
  acl = "private"

  cors_rule {
      allowed_headers = ["Authorization"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      expose_headers = ["ETag"]
      max_age_seconds = 3000
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Id":"GetObjPolicy",
  "Statement":[
    {
      "Sid":"PublicReadForGetBucketObjects",
      "Effect":"Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::cdn.${var.domain}/*"
    }
  ]
}
POLICY

  tags {
    Name = "${var.name_prefix}cdn"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}
