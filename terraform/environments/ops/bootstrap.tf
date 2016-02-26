resource "null_resource" "bootstrap" {
  triggers {
    ops_admin = "${aws_iam_group_membership.admins-ops.id}"
    state_bucket = "${aws_s3_bucket.terraform.id}"
  }
}
