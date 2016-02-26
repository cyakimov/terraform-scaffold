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

variable "aws_account" {
  description = "AWS account id"
}

variable "ops_account" {
  description = "AWS account id for ops env"
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

variable "aws_primary_availability_zone" {
  description = "The primary AWS availability zone to host your network"
}

variable "aws_secondary_availability_zone" {
  description = "The secondary AWS availability zone to host your network"
}

variable "vpc_tenancy" {
  description = "Instance tenancy for the VPC"
  default = "default"
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

variable "enable_upstream_zone" {
  description = "Enables registration of primary zone as a sudomain of an upstream zone"
  default     = 0
}

variable "upstream_zone_id" {
  description = "The upstream zone id for which the primary zone is a subdomain"
  default     = ""
}
