module "core" {
  source = "../../modules/core"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  domain = "${var.domain}"
  internal_domain = "${var.internal_domain}"
  aws_account = "${lookup(var.aws_accounts, var.environment)}"
  ops_account = "${lookup(var.aws_accounts, "ops")}"
  aws_keypair_name = "${var.aws_keypair_name}"
  aws_keypair_path = "${var.aws_keypair_path}"

  ssl_cert = "${var.ssl_cert}"
  ssl_key = "${var.ssl_key}"
  ssl_chain = "${var.ssl_chain}"
  internal_ssl_cert = "${var.internal_ssl_cert}"
  internal_ssl_key = "${var.internal_ssl_key}"
  internal_ssl_chain = "${var.internal_ssl_chain}"

  vpc_tenancy = "${var.vpc_tenancy}"
  vpc_cidr = "${var.vpc_cidr}"
  public_primary_subnet_cidr = "${var.public_primary_subnet_cidr}"
  private_primary_subnet_cidr = "${var.private_primary_subnet_cidr}"
  public_secondary_subnet_cidr = "${var.public_secondary_subnet_cidr}"
  private_secondary_subnet_cidr = "${var.private_secondary_subnet_cidr}"
  aws_primary_availability_zone = "${var.aws_primary_availability_zone}"
  aws_secondary_availability_zone = "${var.aws_secondary_availability_zone}"

  cdn_endpoint = "${var.cdn_endpoint}"

  // enable_upstream_zone = 1
  // upstream_zone_id = "Z3CN6HO7VUY0U3"
}

module "vpn" {
  source = "../../modules/vpn"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  domain = "${var.domain}"
  internal_domain = "${var.internal_domain}"
  aws_keypair_name = "${var.aws_keypair_name}"
  aws_keypair_path = "${var.aws_keypair_path}"
  ops_account = "${lookup(var.aws_accounts, "ops")}"

  vpc_id = "${module.core.vpc_id}"
  subnet_id = "${module.core.primary_public_subnet_id}"
  zone_id = "${module.core.primary_zone_id}"

  security_groups_csv = "${module.core.default_security_group_id}"

  # this, along with vpc_cidr, should be different for each env if you want to
  # connect vpn to multiple envs at same time
  vpn_client_cidr = "${var.vpn_client_cidr}"
  # aws has reserved ip on addr 2 of the vpc for internal dns
  dns_servers_csv = "${cidrhost(var.vpc_cidr, 2)}"

  vpn_ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpn_ca_passphrase = "${var.vpn_ca_passphrase}"
}

// TODO: switch to passing aws_iam_policy arns to module and using
// aws_iam_policy_role_attach when this PR is accepted
// https://github.com/hashicorp/terraform/pull/4251
resource "aws_iam_role_policy" "vpn-s3-backup-attach" {
  name = "${var.name_prefix}vpn-s3-backup-attach"
  role = "${module.vpn.instance_profile_role}"

  policy = "${module.core.ec2_backup_access_policy}"
}


module "ecs-main" {
  source = "../../modules/ecs-cluster"

  environment = "${var.environment}"
  name_prefix = "${var.name_prefix}"
  aws_region = "${var.aws_region}"
  ops_account = "${lookup(var.aws_accounts, "ops")}"

  cluster_name = "main"
  ecs_ami = "${lookup(var.aws_ecs_amis, var.aws_region)}"
  ecs_keypair_name = "${var.aws_keypair_name}"
  ecs_subnet_ids_csv = "${module.core.primary_private_subnet_id},${module.core.secondary_private_subnet_id}"
  ecs_security_groups_csv = "${module.core.default_security_group_id}"
}

resource "aws_iam_role_policy" "ecs-main-cdn-attach" {
  name = "${var.name_prefix}ecs-main-cdn-attach"
  role = "${module.ecs-main.instance_profile_role}"

  policy = "${module.core.ec2_cdn_access_policy}"
}
