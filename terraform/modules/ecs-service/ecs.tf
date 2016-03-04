// Role that allows ecs to manage elb
resource "aws_iam_role" "ecs-service" {
  count = "${var.integrate_with_elb}"

  name = "${var.name_prefix}ecs-service-${var.name}"
  assume_role_policy = <<POLICY
{
"Version": "2008-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ecs.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
POLICY
}

// Add policy for talking to elb into the role
resource "aws_iam_role_policy" "ecs-service" {
  count = "${var.integrate_with_elb}"

  name = "${var.name_prefix}ecs-service-${var.name}"
  role = "${aws_iam_role.ecs-service.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_ecr_repository" "app" {
  name = "${var.name_prefix}${var.name}"
}

resource "template_file" "containers_template" {
  template = "${var.containers_template}"

  vars {
    environment = "${var.environment}"
    name = "${var.name_prefix}${var.name}"
    registry_host = "${aws_ecr_repository.app.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    repository_name = "${aws_ecr_repository.app.name}"
    app_port = "${var.app_port}"
    instance_port = "${var.instance_port}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.name_prefix}${var.name}"
  container_definitions = "${template_file.containers_template.rendered}"
}

// Add in logging grouped to app once available:
// https://github.com/aws/amazon-ecs-agent/pull/251
//
//"logConfiguration": {
//  "logDriver": "syslog",
//  "options": {
//    "awslogs-region": "${var.aws_region}",
//    "awslogs-group": "${aws_cloudwatch_log_group.app.name}"
//  }
//},

resource "aws_ecs_service" "app" {
  count = "${var.integrate_with_elb}"

  name = "${var.name_prefix}${var.name}"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count = "${var.app_container_count}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent = "${var.deployment_maximum_percent}"

  iam_role = "${aws_iam_role.ecs-service.id}"
  depends_on = ["aws_iam_role_policy.ecs-service"]

  // Prevent terraform from needing to make a change due to CI deploy
  // https://github.com/hashicorp/terraform/issues/4663
  // Comment this out when adding new apps
  lifecycle {
    ignore_changes = [
      "task_definition"
    ]
  }

  load_balancer {
    elb_name = "${var.elb_id}"
    container_name = "${var.name_prefix}${var.name}"
    container_port = "${var.app_port}"
  }
}

variable dont_integrate_with_elb {
  default = {
    "0" = 1
    "1" = 0
  }
}

resource "aws_ecs_service" "app-no-lb" {
  count = "${lookup(var.dont_integrate_with_elb, var.integrate_with_elb)}"

  name = "${var.name_prefix}${var.name}"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count = "${var.app_container_count}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent = "${var.deployment_maximum_percent}"

  // Prevent terraform from needing to make a change due to CI deploy
  // https://github.com/hashicorp/terraform/issues/4663
  // Comment this out when adding new apps
  lifecycle {
    ignore_changes = [
      "task_definition"
    ]
  }

}
