resource "aws_security_group" "vpn" {
  name = "${var.name_prefix}vpn"
  vpc_id = "${var.vpc_id}"
  description = "OpenVPN security group"

  tags {
    Name = "${var.name_prefix}vpn"
    Environment = "${var.environment}"
    Source = "terraform"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_instance_profile" "vpn" {
  name  = "${var.name_prefix}vpn"
  path  = "/"
  roles = ["${aws_iam_role.vpn.name}"]
}

resource "aws_iam_role" "vpn" {
  name               = "${var.name_prefix}vpn"
  path               = "/"
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

resource "aws_iam_role_policy" "vpn-iam-inspect" {
  name = "${var.name_prefix}vpn-iam-inspect-attach"
  role = "${aws_iam_role.vpn.name}"
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

resource "template_file" "iam-ssh" {
  template = "${file("${path.module}/../../templates/cloud-init/iam-ssh.template.yml")}"
  vars {
    environment = "${var.environment}"
    ops_account = "${var.ops_account}"
    // limit ssh access to vpn instance to just the ops admins, not all admins for the environment
    iam_group = "admins-ops"
    login_user = "ubuntu"
  }
}

resource "template_file" "vpn-init" {
  template = "${file("${path.module}/files/vpn.yml")}"

  vars {
    module_path = "${path.module}"
    environment = "${var.environment}"
    backup_bucket = "${var.name_prefix}-backup"
  }
}

resource "template_cloudinit_config" "vpn" {
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

  part {
    content_type = "text/cloud-config"
    content = "${template_file.vpn-init.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

resource "aws_instance" "vpn" {
  ami = "${var.vpn_ami}"
  instance_type = "${var.vpn_instance_type}"
  key_name = "${var.aws_keypair_name}"
  subnet_id = "${var.subnet_id}"

  iam_instance_profile = "${aws_iam_instance_profile.vpn.name}"

  user_data = "${template_cloudinit_config.vpn.rendered}"

  vpc_security_group_ids = [
    "${aws_security_group.vpn.id}",
    "${compact(split(",", var.security_groups_csv))}"
  ]

  tags {
    Name = "${var.name_prefix}vpn"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

// Do this separate from cloud-init so we can pass in the passphrase and not
// have it stored on disk on the instance.  Also, reliance on route53 hostname
// causes a cycle - https://github.com/hashicorp/terraform/issues/557
resource "null_resource" "vpn" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    vpn_instance_id = "${aws_instance.vpn.id}"
    vpn_hostname = "${aws_route53_record.vpn.id}"
  }

  connection {
    host = "${aws_eip.vpn.public_ip}"
    user = "ubuntu"
    key_file = "${var.aws_keypair_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "while ! test -f /usr/local/vpn_installed; do echo .; sleep 1; done; PASSPHRASE='${var.vpn_ca_passphrase}' sudo -E /usr/local/bin/vpnbootstrap ${aws_route53_record.vpn.fqdn} ${var.vpn_client_cidr} ${var.internal_domain} ${var.dns_servers_csv}"
    ]
  }
}

resource "aws_eip" "vpn" {
  vpc = true
  instance = "${aws_instance.vpn.id}"
}

resource "aws_route53_record" "vpn" {
  zone_id = "${var.zone_id}"
  name = "vpn.${var.domain}"
  type = "A"
  ttl = "300"
  records = [
    "${aws_eip.vpn.public_ip}"
  ]
}
