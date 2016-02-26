variable "env_accounts_csv" {
  description = "CSV of known aws account numbers"
  default = "1,2,3,4"
}

variable "aws_accounts" {
  description = "Maps environments to account numbers"
  default = {
    ops = "1"
    dev = "2"
    staging = "3"
    production = "4"
  }
}

variable "terraform_bucket_name" {
  description = "The s3 bucket to store terraform state/secrets in"
  default = "acme-ops-terraform"
}

variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments"
}

variable "domain" {
  description = "The primary domain"
}

variable "internal_domain" {
  description = "The internal domain"
}

variable "aws_region" {
  description = "The aws region"
}

variable "aws_keypair_name" {
  description = "AWS keypair name"
}

variable "aws_keypair_path" {
  description = "Path to AWS keypair private key"
}

variable "ssl_cert" {
  description = "The ssl cert for the domain"
}

variable "ssl_key" {
  description = "The ssl key for the cert for the domain"
}

variable "ssl_chain" {
  description = "The ssl CA chain for the cert for the domain"
}

variable "internal_ssl_cert" {
  description = "The ssl cert for the internal domain"
}

variable "internal_ssl_key" {
  description = "The ssl key for the cert for the internal domain"
}

variable "internal_ssl_chain" {
  description = "The ssl CA chain for the cert for the internal domain"
}

variable "cdn_endpoint" {
  description = "The endpoint to map the cdn dns record to (e.g. cdn.dev.acme.com.s3.amazonaws.com or xxxyyyzzz.cloudfront.net if using cloudfront)"
}

variable "vpn_ca_passphrase" {
  description = "The passphrase for the CA used for OpenVPN certificates"
}

variable "vpn_client_cidr" {
  description = "The cidr to allocate vpn client connections on"
  default = "192.168.255.0/24"
}

variable "aws_primary_availability_zone" {
  description = "The primary AWS availability zone to host your network"
}

variable "aws_secondary_availability_zone" {
  description = "The secondary AWS availability zone to host your network"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.10.0.0/16"
}

variable "public_primary_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.10.0.0/24"
}

variable "private_primary_subnet_cidr" {
  description = "CIDR for primary private subnet"
  default     = "10.10.1.0/24"
}

variable "public_secondary_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.10.10.0/24"
}

variable "private_secondary_subnet_cidr" {
  description = "CIDR for secondary private subnet"
  default     = "10.10.11.0/24"
}

variable "vpc_tenancy" {
  description = "Instance tenancy for the VPC"
  default = "default"
}

// Ubuntu 14.04 amis by region
// https://cloud-images.ubuntu.com/locator/ec2/
variable "aws_amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-east-1 = "ami-5c207736" # hvm:ebs-ssd
  }
}

// http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
variable "aws_ecs_amis" {
  description = "Base AMI to launch ECS instances with"
  default = {
    us-east-1 = "ami-2b3b6041" # amazon ecs instance
  }
}
