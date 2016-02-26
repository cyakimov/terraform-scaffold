resource "aws_iam_group" "admins-ops" {
  name = "admins-ops"

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }

  path = "/"
}

resource "aws_iam_group_policy" "admins-ops" {
  name = "admins-ops"
  group = "${aws_iam_group.admins-ops.name}"

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_group_membership" "admins-ops" {
  name  = "admins-ops"
  users = [
    "${aws_iam_user.super_admin.name}",
  ]
  group = "${aws_iam_group.admins-ops.name}"

  depends_on = ["aws_iam_group_policy.admins-ops"]

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }
}

resource "aws_iam_group" "admins-production" {
  name = "admins-production"
  path = "/"
}

resource "aws_iam_group_policy" "admins-production" {
  name = "admins-production"
  group = "${aws_iam_group.admins-production.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${lookup(var.aws_accounts, "production")}:role/ops-admin"
    }
}
EOF
}

resource "aws_iam_group_membership" "admins-production" {
  name  = "admins-production"
  users = [
    "${aws_iam_user.super_admin.name}",
  ]
  group = "${aws_iam_group.admins-production.name}"
}

resource "aws_iam_group" "admins-staging" {
  name = "admins-staging"
  path = "/"
}

resource "aws_iam_group_policy" "admins-staging" {
  name = "admins-staging"
  group = "${aws_iam_group.admins-staging.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${lookup(var.aws_accounts, "staging")}:role/ops-admin"
    }
}
EOF
}

resource "aws_iam_group_membership" "admins-staging" {
  name  = "admins-staging"
  users = [
    "${aws_iam_user.super_admin.name}",
  ]
  group = "${aws_iam_group.admins-staging.name}"
}

resource "aws_iam_group" "admins-dev" {
  name = "admins-dev"
  path = "/"
}

resource "aws_iam_group_policy" "admins-dev" {
  name = "admins-dev"
  group = "${aws_iam_group.admins-dev.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${lookup(var.aws_accounts, "dev")}:role/ops-admin"
    }
}
EOF
}

resource "aws_iam_group_membership" "admins-dev" {
  name  = "admins-dev"
  users = [
    "${aws_iam_user.super_admin.name}",
  ]
  group = "${aws_iam_group.admins-dev.name}"
}

resource "aws_iam_user" "deployer" {
  name = "deployer"
  path = "/"
}

resource "aws_iam_user_policy" "deployer" {
  name = "${var.name_prefix}deployer"
  user = "${aws_iam_user.deployer.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
          ${join(",", formatlist("\"arn:aws:iam::%s:role/ops-deployer\"", split(",", var.env_accounts_csv)))}
        ]
    }
}
EOF
}

resource "aws_iam_group" "all-users" {
  name = "${var.name_prefix}all-users"
  path = "/"
}

resource "aws_iam_group_membership" "all-users" {
  name  = "${var.name_prefix}all-users"
  group = "${aws_iam_group.all-users.name}"
  users = [
    "${aws_iam_user.super_admin.name}",
  ]
}

resource "aws_iam_group_policy" "self-management" {
  name = "${var.name_prefix}self-management"
  group = "${aws_iam_group.all-users.name}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*LoginProfile",
        "iam:*AccessKey*",
        "iam:*SSHPublicKey*"
      ],
      "Resource": "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:user/$${aws:username}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListAccount*",
        "iam:GetAccountSummary",
        "iam:GetAccountPasswordPolicy",
        "iam:ListUsers"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowUsersToCreateEnableResyncTheirOwnVirtualMFADevice",
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:mfa/$${aws:username}",
        "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowUsersToDeactivateDeleteTheirOwnVirtualMFADevice",
      "Effect": "Allow",
      "Action": [
        "iam:DeactivateMFADevice",
        "iam:DeleteVirtualMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:mfa/$${aws:username}",
        "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:user/$${aws:username}"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Sid": "AllowUsersToListMFADevicesandUsersForConsole",
      "Effect": "Allow",
      "Action": [
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ListUsers"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "iam-inspect" {
  name               = "iam-inspect"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          ${join(",", formatlist("\"arn:aws:iam::%s:root\"", split(",", var.env_accounts_csv)))}
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "iam-inspect" {
  name = "iam-inspect"
  role = "${aws_iam_role.iam-inspect.name}"

  policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetGroup",
        "iam:ListSshPublicKeys",
        "iam:GetSshPublicKey"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user" "super_admin" {
  name = "SuperAdmin"
  path = "/"
}
