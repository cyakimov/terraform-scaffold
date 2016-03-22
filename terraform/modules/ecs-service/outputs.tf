output "registry_host" {
  value = "${element(aws_ecr_repository.app.*.registry_id, var.create_repository)}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "repository_name" {
  value = "${element(aws_ecr_repository.app.*.name, var.create_repository)}"
}

output "app_port" {
  value = "${var.app_port}"
}

output "instance_port" {
  value = "${var.instance_port}"
}
