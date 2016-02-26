resource "aws_iam_role" "ops-admin" {
  name  = "ops-admin"
  path  = "/"

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
//"Condition": {
//  "Bool": {
//    "aws:MultiFactorAuthPresent": "true"
//  }
//}

resource "aws_iam_role_policy" "ops-admin" {
  name = "ops-admin"
  role = "${aws_iam_role.ops-admin.name}"

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

resource "aws_iam_role" "ops-deployer" {
  name = "ops-deployer"
  path = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${lookup(var.aws_accounts, "ops")}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ops-deployer" {
  name = "ops-deployer"
  role = "${aws_iam_role.ops-deployer.name}"
  policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:List*",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService",
        "ecr:Describe*",
        "ecr:List*",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:BatchDeleteImage"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
