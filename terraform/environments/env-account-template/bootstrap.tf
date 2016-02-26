resource "null_resource" "bootstrap" {
  triggers {
    ops_admin = "${aws_iam_role_policy.ops-admin.id}"
  }
}
