output "hostname" {
  value = "${aws_route53_record.app-db.fqdn}"
}

output "port" {
  value = "${aws_db_instance.app.port}"
}

output "database" {
  value = "${aws_db_instance.app.name}"
}

output "username" {
  value = "${aws_db_instance.app.username}"
}

output "password" {
  value = "${aws_db_instance.app.password}"
}
