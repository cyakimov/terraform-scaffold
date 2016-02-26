resource "aws_s3_bucket" "terraform" {
  bucket = "${var.terraform_bucket_name}"
  acl = "private"

  versioning {
    enabled = true
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Id":"PutObjPolicy",
  "Statement":[
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.terraform_bucket_name}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "GiveEnvAccountsAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [${join(",", formatlist("\"arn:aws:iam::%s:root\"", split(",", var.env_accounts_csv)))}]
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${var.terraform_bucket_name}",
        "arn:aws:s3:::${var.terraform_bucket_name}/*"
      ]
    }
  ]
}
POLICY
  // Note that even though we grant access to all root accounts to * in this
  // bucket, when we place the files, we do it as the assumed user, and thus
  // the object level permissions get set for that user, and other user's can't
  // access the file.  Thus if a user only has access to dev account, it won't
  // be able to see the data in this bucket for the staging/prod accounts
  tags {
    Name = "${var.name_prefix}terraform"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}
