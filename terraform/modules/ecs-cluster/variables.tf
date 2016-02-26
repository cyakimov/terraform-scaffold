variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments on the same account"
}

variable "aws_region" {
  description = "The aws region"
}

variable "ops_account" {
  description = "AWS account id for ops env"
}

variable "cluster_name" {
  description = "The cluster name"
}

variable "ecs_ami" {
  description = "The ami to use for ecs instances"
}

variable "ecs_keypair_name" {
  description = "AWS keypair name to use for ecs instances"
}

variable "ecs_subnet_ids_csv" {
  description = "The subnets to run ecs instances on"
}

variable "ecs_security_groups_csv" {
  description = "Security groups to attach to the ecs instances"
  default = ""
}

variable "ecs_instance_type" {
  description = "The instance type to use for ecs instances"
  default = "m3.medium"
}

variable "ecs_instance_max" {
  description = "The max number of ecs instances allowed"
  default = 8
}

variable "ecs_instance_min" {
  description = "The min number of ecs instances allowed"
  default = 2
}

variable "ecs_instance_desired" {
  description = "The desired number of ecs instances"
  default = 4
}
