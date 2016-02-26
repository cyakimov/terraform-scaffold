output "registry_host" {
  value = "${aws_ecr_repository.app.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "repository_name" {
  value = "${aws_ecr_repository.app.name}"
}

output "app_port" {
  value = "${var.app_port}"
}

output "instance_port" {
  value = "${var.instance_port}"
}
