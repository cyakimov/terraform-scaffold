output "hostname" {
  value = "${aws_route53_record.app.fqdn}"
}

output "elb_id" {
  value = "${aws_elb.app.id}"
}

output "elb_zone_id" {
  value = "${aws_elb.app.zone_id}"
}

output "elb_dns_name" {
  value = "${aws_elb.app.dns_name}"
}
