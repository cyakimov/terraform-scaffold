output "hostname" {
  value = "${aws_route53_record.app.fqdn}"
}

output "port" {
  value = "${var.port}"
}
