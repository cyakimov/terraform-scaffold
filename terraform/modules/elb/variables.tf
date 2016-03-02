variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments on the same account"
}

variable "name" {
  description = "The component name"
}

variable "instance_port" {
  description = "The port for the app server hit by the load balancer"
}

variable "zone_id" {
  description = "The zone id for registering the endpoint - can be public or private"
}

variable "subnet_ids_csv" {
  description = "The subnet ids for components that need them - can be public or private"
}

variable "security_groups_csv" {
  description = "The security groups associated with the instance"
}

variable "elb_certificate_arn" {
  description = "The ssl certificate for the ELB instance"
}

variable "logs_bucket" {
  description = "The bucket to use for logging"
}

variable "internal" {
  description = "Makes the ELB intenal facing (also need to set subnets to private, and zone to internal)"
}

variable "health_check_path" {
  description = "The url path to hit on the app server to determine health"
  default = "/health-check/"
}

variable "health_check_timeout" {
  description = "Timeout when connecting to determine health"
  default = 3
}

variable "health_check_interval" {
  description = "Time period in secs between health checks"
  default = 30
}

variable "health_check_unhealthy_threshold" {
  description = "The number of health checks that need to fail before marking unhealthy"
  default = 4
}

variable "health_check_healthy_threshold" {
  description = "The number of health checks that need to pass before marking healthy"
  default = 2
}
