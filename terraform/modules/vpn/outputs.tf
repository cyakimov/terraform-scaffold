output "instance_profile" {
  value = "${aws_iam_instance_profile.vpn.name}"
}

output "instance_profile_role" {
  value = "${aws_iam_role.vpn.name}"
}
