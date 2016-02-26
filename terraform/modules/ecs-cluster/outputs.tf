output "cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "instance_profile" {
  value = "${aws_iam_instance_profile.ecs.name}"
}

output "instance_profile_role" {
  value = "${aws_iam_role.ecs.name}"
}

output "log_group" {
  value = "${aws_cloudwatch_log_group.ecs-main.name}"
}
