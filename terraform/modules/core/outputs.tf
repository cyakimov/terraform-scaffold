output "vpc_id" {
  value = "${aws_vpc.primary.id}"
}

output "primary_public_subnet_id" {
  value = "${aws_subnet.public-primary.id}"
}

output "primary_private_subnet_id" {
  value = "${aws_subnet.private-primary.id}"
}

output "secondary_public_subnet_id" {
  value = "${aws_subnet.public-secondary.id}"
}

output "secondary_private_subnet_id" {
  value = "${aws_subnet.private-secondary.id}"
}

output "primary_zone_id" {
  value = "${aws_route53_zone.primary.zone_id}"
}

output "internal_zone_id" {
  value = "${aws_route53_zone.internal.zone_id}"
}

output "default_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "web_security_group_id" {
  value = "${aws_security_group.web.id}"
}

output "domain_cert_arn" {
  value = "${aws_iam_server_certificate.domain-cert.arn}"
}

output "internal_domain_cert_arn" {
  value = "${aws_iam_server_certificate.internal-domain-cert.arn}"
}

output "ec2_cdn_access_policy" {
  value = "${aws_iam_role_policy.ec2-cdn-access.policy}"
}

output "cdn_bucket" {
  value = "${aws_s3_bucket.cdn.bucket}"
}

output "cdn_hostname" {
  value = "${aws_route53_record.cdn.fqdn}"
}

output "ec2_backup_access_policy" {
  value = "${aws_iam_role_policy.ec2-backup-access.policy}"
}

output "instance_profile" {
  value = "${aws_iam_instance_profile.ec2-default-profile.name}"
}

output "instance_profile_role" {
  value = "${aws_iam_role.ec2-default-role.name}"
}

output "logs_bucket" {
  value = "${aws_s3_bucket.logs.bucket}"
}
