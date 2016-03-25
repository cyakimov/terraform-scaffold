// Have to create this outside of module to allow editing for now
// https://github.com/hashicorp/terraform/issues/3388
//
//resource "aws_db_parameter_group" "app" {
//  name = "${var.name_prefix}${var.name}"
//  family = "postgres9.3"
//  description = "RDS parameter group for ${var.name} app"
//
////  // These settings turn on db logging for performance analysis with a tool like
// //  // pgbadger
// //  //
// //  //  parameter {
// //  //    name = "log_statement"
// //  //    value = "none"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_min_duration_statement"
// //  //    value = "0"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_checkpoints"
// //  //    value = "on"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_connections"
// //  //    value = "on"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_disconnections"
// //  //    value = "on"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_lock_waits"
// //  //    value = "on"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_temp_files"
// //  //    value = "0"
// //  //    apply_method = "immediate"
// //  //  }
// //  //  parameter {
// //  //    name = "log_autovacuum_min_duration"
// //  //    value = "0"
// //  //    apply_method = "immediate"
// //  //  }
//}

resource "aws_db_subnet_group" "app" {
  name = "${var.name_prefix}${var.name}"
  description = "The db subnets for ${var.name}"

  subnet_ids = ["${split(",", var.subnet_ids_csv)}"]

  tags {
    Name = "${var.name_prefix}${var.name}"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_db_instance" "app" {
  identifier = "${var.name_prefix}${var.name}"

  engine = "${var.engine}"
  engine_version = "${var.engine_version}"

  instance_class = "${var.db_instance_type}"
  allocated_storage = "${var.db_instance_storage}"
  storage_encrypted = "${var.encrypted}"
  storage_type = "${var.db_instance_storage_type}"
  iops = "${var.db_instance_storage_iops}"

  multi_az = "${var.multi_az}"
  backup_retention_period = "${var.backup_retention_period}"
  final_snapshot_identifier = "${var.name_prefix}${var.name}-final"
  skip_final_snapshot = false
  // Uncomment to rebuild from final if recreating
  // snapshot_identifier = "${var.name_prefix}${var.name}-final"

  username = "${var.db_username}"
  password = "${var.db_password}"
  name = "${var.db_name}"

  db_subnet_group_name = "${aws_db_subnet_group.app.name}"
  parameter_group_name = "${var.parameter_group_name}"

  vpc_security_group_ids = ["${compact(split(",", var.security_groups_csv))}"]

  tags {
    Name = "${var.name_prefix}${var.name}"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route53_record" "app-db" {
  zone_id = "${var.zone_id}"
  name = "${var.name}-db"
  type = "CNAME"
  ttl = "300"

  records = [
    "${aws_db_instance.app.address}"
  ]
}
