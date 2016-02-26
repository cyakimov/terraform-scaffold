resource "aws_route53_zone" "primary" {
  name = "${var.domain}"

  tags {
    Name = "${var.name_prefix}primary-zone"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

// TODO: This doesn't work as we assume role for one env, but this zone in a different env
// Creating NS record in production domain manually for now
// We could use a null_resource and call out to aws cli
// Or we could try using IAM roles/policies/etc to do it
resource "aws_route53_record" "primary-ns" {
  count = "${var.enable_upstream_zone}"
  zone_id = "${var.upstream_zone_id}"
  name = "${aws_route53_zone.primary.name}"
  type = "NS"
  ttl = "300"

  records = [
      "${aws_route53_zone.primary.name_servers.0}",
      "${aws_route53_zone.primary.name_servers.1}",
      "${aws_route53_zone.primary.name_servers.2}",
      "${aws_route53_zone.primary.name_servers.3}"
  ]
}

resource "aws_route53_zone" "internal" {
  name = "${var.internal_domain}"
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "${var.name_prefix}internal-zone"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route53_record" "internal-ns" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "${aws_route53_zone.internal.name}"
  type = "NS"
  ttl = "300"

  records = [
      "${aws_route53_zone.internal.name_servers.0}",
      "${aws_route53_zone.internal.name_servers.1}",
      "${aws_route53_zone.internal.name_servers.2}",
      "${aws_route53_zone.internal.name_servers.3}"
  ]
}

resource "aws_route53_record" "root" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${aws_s3_bucket.root-domain-redirect.website_domain}"
    zone_id = "${aws_s3_bucket.root-domain-redirect.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "cdn"
  type = "CNAME"
  ttl = "300"

  records = [
    "${var.cdn_endpoint}"
  ]
}
