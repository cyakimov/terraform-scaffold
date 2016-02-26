resource "aws_route53_record" "app" {
  zone_id = "${var.zone_id}"
  name = "${var.name}"
  type = "A"

  alias {
    name = "${aws_elb.app.dns_name}"
    zone_id = "${aws_elb.app.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_elb" "app" {
  name = "${var.name_prefix}${var.name}"

  internal = "${var.internal}"

  subnets = ["${split(",", var.subnet_ids_csv)}"]

  security_groups = ["${compact(split(",", var.security_groups_csv))}"]


  access_logs {
    bucket = "${var.logs_bucket}"
    bucket_prefix = "${var.name}-elb-access"
    interval = 60
  }

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certificate_arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "HTTP:${var.instance_port}/health-check"
    interval = 5
  }

  tags {
    Name = "${var.name_prefix}${var.name}"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}
