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
    instance_protocol = "tcp"
    lb_port = "${var.lb_port}"
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout = "${var.health_check_timeout}"
    interval = "${var.health_check_interval}"
    target = "TCP:${var.instance_port}"
  }

  tags {
    Name = "${var.name_prefix}${var.name}"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}
