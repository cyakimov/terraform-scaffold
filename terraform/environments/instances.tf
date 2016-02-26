resource "template_file" "iam-ssh" {
  template = "${file("../../templates/cloud-init/iam-ssh.template.yml")}"
  vars {
    environment = "${var.environment}"
    ops_account = "${lookup(var.aws_accounts, "ops")}"
    iam_group = "admins-${var.environment}"
    login_user = "ubuntu"
  }
}

resource "template_cloudinit_config" "util" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = "${file("../../templates/cloud-init/util.yml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${file("../../templates/cloud-init/docker.yml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${file("../../templates/cloud-init/postgresql-client.yml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${template_file.iam-ssh.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

resource "aws_instance" "util" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "m3.medium"
  subnet_id = "${module.core.primary_private_subnet_id}"
  key_name = "${var.aws_keypair_name}"

  iam_instance_profile = "${module.core.instance_profile}"

  vpc_security_group_ids = [
    "${module.core.default_security_group_id}"
  ]

  user_data = "${template_cloudinit_config.util.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  tags = {
    Name = "${var.name_prefix}util"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route53_record" "util" {
  zone_id = "${module.core.internal_zone_id}"
  name = "util"
  type = "A"
  ttl = "300"

  records = [
    "${aws_instance.util.private_ip}"
  ]
}
