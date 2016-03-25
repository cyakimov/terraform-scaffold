resource "aws_db_parameter_group" "myapp-rds" {
  name = "${var.name_prefix}myapp"
  family = "postgres9.4"
  description = "RDS parameter group for myapp app"

//  parameter {
//    name = "statement_timeout"
//    value = "3600"
//    apply_method = "immediate"
//  }
}

module "myapp-rds" {
  source = "../../modules/rds"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  name = "myapp"

  zone_id = "${module.core.internal_zone_id}"
  subnet_ids_csv = "${module.core.primary_private_subnet_id},${module.core.secondary_private_subnet_id}"
  security_groups_csv = "${module.core.default_security_group_id}"
  parameter_group_name = "${aws_db_parameter_group.myapp-rds.name}"
}

resource "aws_elasticache_parameter_group" "myapp-redis" {
  name = "${var.name_prefix}myapp-redis"
  family = "redis2.8"
  description = "${var.name_prefix}myapp-redis param group"
}

module "myapp-redis" {
  source = "../../modules/elasticache"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  name = "myapp-redis"

  zone_id = "${module.core.internal_zone_id}"
  subnet_ids_csv = "${module.core.primary_private_subnet_id},${module.core.secondary_private_subnet_id}"
  security_groups_csv = "${module.core.default_security_group_id}"
  parameter_group_name = "${aws_elasticache_parameter_group.myapp-redis.name}"

  family = "redis2.8"
  engine = "redis"
  port = "6379"
  snapshot_limit = 3
}

module "myapp-elb" {
  source = "../../modules/elb"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  name = "myapp"

  internal = false
  zone_id = "${module.core.primary_zone_id}"
  subnet_ids_csv = "${module.core.primary_public_subnet_id},${module.core.secondary_public_subnet_id}"
  security_groups_csv = "${module.core.default_security_group_id},${module.core.web_security_group_id}"

  instance_port = 8000
  logs_bucket = "${module.core.logs_bucket}"
  elb_certificate_arn = "${module.core.domain_cert_arn}"
}

module "myapp-ecs-service" {
  source = "../../modules/ecs-service"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  name = "myapp"
  aws_region = "${var.aws_region}"

  ecs_cluster_id = "${module.ecs-main.cluster_id}"
  elb_id = "${module.myapp-elb.elb_id}"

  app_port = 8000
  instance_port = 8000

  containers_template = <<TMPL
    [
      {
        "name": "$${name}",
        "image": "$${registry_host}/$${repository_name}:latest",
        "command": ["app"],
        "memory": 500,
        "portMappings": [
          {
            "hostPort": $${instance_port},
            "containerPort": $${app_port}
          }
        ],
        "environment" : [
            { "name" : "APP_ENV", "value" : "${var.environment}" },
            { "name" : "APP_PORT", "value" : "$${app_port}" },
            { "name" : "DB_HOST", "value" : "${module.myapp-rds.hostname}" },
            { "name" : "DB_PORT", "value" : "${module.myapp-rds.port}" },
            { "name" : "DB_NAME", "value" : "${module.myapp-rds.database}" },
            { "name" : "DB_USER", "value" : "${module.myapp-rds.username}" },
            { "name" : "DB_PASS", "value" : "${module.myapp-rds.password}" },
            { "name" : "REDIS_URL", "value" : "redis://${module.myapp-redis.hostname}:${module.myapp-redis.port}/0" },
        ]
      }
    ]
TMPL

}

module "myapp-worker-ecs-service" {
  source = "../../modules/ecs-service"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  name = "myapp-worker"
  aws_region = "${var.aws_region}"

  ecs_cluster_id = "${module.ecs-main.cluster_id}"
  integrate_with_elb = 0
  elb_id = ""
  app_port = 0
  instance_port = 0

  // Same image as myapp-ecs-service
  containers_template = <<TMPL
    [
      {
        "name": "$${name}",
        "image": "${module.myapp-ecs-service.registry_host}/${module.myapp-ecs-service.repository_name}:latest",
        "command": ["worker"],
        "memory": 500,
        "environment" : [
            { "name" : "APP_ENV", "value" : "${var.environment}" },
            { "name" : "APP_PORT", "value" : "$${app_port}" },
            { "name" : "DB_HOST", "value" : "${module.myapp-rds.hostname}" },
            { "name" : "DB_PORT", "value" : "${module.myapp-rds.port}" },
            { "name" : "DB_NAME", "value" : "${module.myapp-rds.database}" },
            { "name" : "DB_USER", "value" : "${module.myapp-rds.username}" },
            { "name" : "DB_PASS", "value" : "${module.myapp-rds.password}" },
            { "name" : "REDIS_URL", "value" : "redis://${module.myapp-redis.hostname}:${module.myapp-redis.port}/0" },
        ]
      }
    ]
TMPL

}
