output "hostname" {
  value = "${aws_route53_record.app.fqdn}"
}

output "elb_id" {
  value = "${aws_elb.app.id}"
}
