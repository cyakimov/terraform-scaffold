variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments on the same account"
}

variable "domain" {
  description = "The primary domain name"
}

variable "internal_domain" {
  description = "The internal domain name"
}

variable "ops_account" {
  description = "AWS account id for ops env"
}

variable "vpc_id" {
  description = "The vpc to install the vpn in"
}

variable "dns_servers_csv" {
  description = "The dns servers"
}

variable "vpn_client_cidr" {
  description = "The cidr von clients will exist on"
}

variable "subnet_id" {
  description = "The subnet to install the vpn instance in"
}

variable "security_groups_csv" {
  description = "Additional security groups to attach to the vpn instance"
}

variable "zone_id" {
  description = "The zone to install the vpn record into"
}

variable "vpn_ca_passphrase" {
  description = "The passphrase for the CA used for OpenVPN certificates"
}

variable "aws_keypair_name" {
  description = "AWS keypair name"
}

variable "aws_keypair_path" {
  description = "Path to AWS keypair private key"
}

variable "vpn_ami" {
  description = "The AMI to use for the vpn instance"
}

variable "vpn_instance_type" {
  description = "The instance type to use for the vpn instance"
  default = "m3.medium"
}
