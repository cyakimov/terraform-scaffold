resource "aws_iam_instance_profile" "ec2-default-profile" {
  name  = "${var.name_prefix}ec2-default-profile"
  path  = "/"
  roles = ["${aws_iam_role.ec2-default-role.name}"]
}

resource "aws_iam_role" "ec2-default-role" {
  name               = "${var.name_prefix}ec2-default-role"
  path               = "/"
  assume_role_policy = "${file("${path.module}/files/policy-assume-role-ec2.json")}"
}

resource "aws_iam_role_policy" "ec2-default-role-policy" {
  name = "${var.name_prefix}ec2-default-role-policy"
  role = "${aws_iam_role.ec2-default-role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ec2-default-iam-inspect-attach" {
  name = "${var.name_prefix}ec2-default-iam-inspect-attach"
  role = "${aws_iam_role.ec2-default-role.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.ops_account}:role/iam-inspect"
    }
}
EOF
}

// policy document to give full access to s3 cdn
resource "aws_iam_role_policy" "ec2-cdn-access" {
  name = "${var.name_prefix}ec2-cdn-access"
  role = "${aws_iam_role.ec2-default-role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.cdn.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.cdn.bucket}/*"
      ]
    }
  ]
}
POLICY
}

// policy document to give full access to s3 backup bucket
resource "aws_iam_role_policy" "ec2-backup-access" {
  name = "${var.name_prefix}ec2-backup-access"
  role = "${aws_iam_role.ec2-default-role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.backup.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.backup.bucket}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_server_certificate" "domain-cert" {
  name = "${var.name_prefix}cert-${var.domain}"
  certificate_body = "${var.ssl_cert}" #"${file("files/${var.domain}.crt")}"
  private_key = "${var.ssl_key}" #"${file("files/${var.domain}.key")}"
  certificate_chain = "${var.ssl_chain}"
}

resource "aws_iam_server_certificate" "internal-domain-cert" {
  name = "${var.name_prefix}cert-${var.internal_domain}"
  certificate_body = "${var.internal_ssl_cert}"
  private_key = "${var.internal_ssl_key}"
  certificate_chain = "${var.internal_ssl_chain}"
}

resource "aws_iam_server_certificate" "domain-cert-cloudfront" {
  name = "${var.name_prefix}cloudfront-cert-${var.domain}"
  certificate_body = "${var.ssl_cert}"
  private_key = "${var.ssl_key}"
  certificate_chain = "${var.ssl_chain}"
  path = "/cloudfront/"
}
