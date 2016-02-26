resource "aws_vpc" "primary" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "${var.vpc_tenancy}"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name_prefix}primary-vpc"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_vpc_dhcp_options" "internal-dhcp-options" {
  // Some OSes may have trouble with multiple domains here, if so nix the ec2.internal one
  domain_name = "${aws_route53_zone.internal.name} ec2.internal"

  // maps to "${cidrhost(var.vpc_cidr, 2)}", which goes to our route53 internal zone
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.name_prefix}internal-dhcp-options"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_vpc_dhcp_options_association" "internal-dhcp-options" {
  vpc_id = "${aws_vpc.primary.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.internal-dhcp-options.id}"
}
