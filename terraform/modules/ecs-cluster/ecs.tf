resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}${var.cluster_name}"
}

// Instance profile that allows instances to add the role
// AWS limits one role per instance profile
resource "aws_iam_instance_profile" "ecs" {
    name  = "${var.name_prefix}ecs-${var.cluster_name}"
    path  = "/"
    roles = ["${aws_iam_role.ecs.name}"]
}

// Role that allows ec2 instances that are nodes in ecs to talk to ecs/ecr
resource "aws_iam_role" "ecs" {
  name = "${var.name_prefix}ecs-${var.cluster_name}"
  assume_role_policy = <<POLICY
{
"Version": "2008-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
POLICY
}

resource "aws_iam_role_policy" "ecs" {
  name = "${var.name_prefix}ecs-${var.cluster_name}"
  role = "${aws_iam_role.ecs.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ecs-iam-inspect" {
  name = "${var.name_prefix}ecs-main-iam-inspect-attach"
  role = "${aws_iam_role.ecs.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.ops_account}:role/iam-inspect"
    }
}
EOF
}


resource "aws_iam_role_policy" "ecs-logs" {
  name = "${var.name_prefix}ecs-logs-${var.cluster_name}"
  role = "${aws_iam_role.ecs.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
POLICY
}

resource "aws_cloudwatch_log_group" "ecs-main" {
  name = "${var.name_prefix}ecs-${var.cluster_name}"
  retention_in_days = 30
}

resource "template_file" "iam-ssh" {
  template = "${file("../../templates/cloud-init/iam-ssh.template.yml")}"
  vars {
    environment = "${var.environment}"
    ops_account = "${var.ops_account}"
    iam_group = "admins-${var.environment}"
    login_user = "ec2-user"
  }
}

resource "template_cloudinit_config" "ecs" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = "${file("../../templates/cloud-init/util.yml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${template_file.iam-ssh.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/x-shellscript"
    // https://docs.docker.com/engine/admin/logging/splunk/
    // export LOCAL_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
    content = <<CONTENT
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
${var.ecs_instance_user_data}
CONTENT
  }

}

resource "aws_launch_configuration" "ecs-main" {
  name_prefix = "${var.name_prefix}ecs-${var.cluster_name}-"
  image_id = "${var.ecs_ami}"
  instance_type = "${var.ecs_instance_type}"
  key_name = "${var.ecs_keypair_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"

  user_data = "${template_cloudinit_config.ecs.rendered}"

  security_groups = [
    "${compact(split(",", var.ecs_security_groups_csv))}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-main" {
  name = "${var.name_prefix}ecs-${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.ecs-main.name}"

  // Note that since we map a host port per app for ELB, and we run at least 2
  // app servers, when deploying a new version of the app, there has to be more
  // instances available than the number of app servers so that ecs can spin up
  // new before tearing down old.  Once ELB allows mapping direct to a
  // container port, then we can revisit
  max_size = "${var.ecs_instance_max}"
  min_size = "${var.ecs_instance_min}"
  desired_capacity = "${var.ecs_instance_desired}"

  vpc_zone_identifier = [
    "${compact(split(",", var.ecs_subnet_ids_csv))}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag = {
    key = "Name"
    value = "${var.name_prefix}ecs-${var.cluster_name}"
    propagate_at_launch = true
  }
  tag = {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag = {
    key = "Source"
    value = "terraform"
    propagate_at_launch = true
  }
}

//resource "aws_autoscaling_policy" "ecs-main" {
//    name = "${var.name_prefix}ecs-${var.cluster_name}"
//    scaling_adjustment = 2
//    adjustment_type = "ChangeInCapacity"
//    cooldown = 300
//    autoscaling_group_name = "${aws_autoscaling_group.ecs-main.name}"
//}
//
//resource "aws_cloudwatch_metric_alarm" "ecs-main-memory" {
//    alarm_name = "${var.name_prefix}ecs-${var.cluster_name}-memory"
//    comparison_operator = "GreaterThanOrEqualToThreshold"
//    evaluation_periods = "2"
//    metric_name = "MemoryUtilization"
//    namespace = "AWS/EC2"
//    period = "120"
//    statistic = "Average"
//    threshold = "80"
//    dimensions {
//        AutoScalingGroupName = "${aws_autoscaling_group.ecs-main.name}"
//    }
//    alarm_description = "This metric monitors ec2 memory utilization"
//    alarm_actions = ["${aws_autoscaling_policy.ecs-main.arn}"]
//}
//
//resource "aws_cloudwatch_metric_alarm" "ecs-main-cpu" {
//    alarm_name = "${var.name_prefix}ecs-${var.cluster_name}-cpu"
//    comparison_operator = "GreaterThanOrEqualToThreshold"
//    evaluation_periods = "2"
//    metric_name = "CPUUtilization"
//    namespace = "AWS/EC2"
//    period = "120"
//    statistic = "Average"
//    threshold = "80"
//    dimensions {
//        AutoScalingGroupName = "${aws_autoscaling_group.ecs-main.name}"
//    }
//    alarm_description = "This metric monitors ec2 cpu utilization"
//    alarm_actions = ["${aws_autoscaling_policy.ecs-main.arn}"]
//}
