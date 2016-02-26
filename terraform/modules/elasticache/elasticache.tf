resource "aws_elasticache_parameter_group" "app" {
  name = "${var.name_prefix}${var.name}"
  family = "${var.family}"
  description = "${var.name_prefix}${var.name} param group"
}

resource "aws_elasticache_subnet_group" "app" {
  name = "${var.name_prefix}${var.name}"
  description = "${var.name_prefix}${var.name} subnet group"
  subnet_ids = ["${split(",", var.subnet_ids_csv)}"]
}

resource "aws_elasticache_cluster" "app" {
  cluster_id = "${var.name_prefix}${var.name}"
  engine = "${var.engine}"
  node_type = "${var.node_type}"
  port = "${var.port}"
  num_cache_nodes = "${var.node_count}"

  snapshot_retention_limit = 3

  parameter_group_name = "${aws_elasticache_parameter_group.app.name}"
  subnet_group_name = "${aws_elasticache_subnet_group.app.name}"
  security_group_ids = ["${compact(split(",", var.security_groups_csv))}"]
}

resource "aws_route53_record" "app" {
  zone_id = "${var.zone_id}"
  name = "${var.name}"
  type = "CNAME"
  ttl = "300"

  records = [
    "${aws_elasticache_cluster.app.cache_nodes.0.address}"
  ]
}
