variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments on the same account"
}

variable "name" {
  description = "The component name"
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

variable "parameter_group_name" {
  description = "The parameter group associated with the instance"
  default = ""
}

variable "engine" {
  description = "The elasticache engine: memcached, redis"
}

variable "port" {
  description = "The elasticache port"
}

variable "node_type" {
  description = "The elasticache node type"
  default = "cache.m3.medium"
}

variable "node_count" {
  description = "The number of elasticache nodes"
  default = "1"
}

variable "snapshot_limit" {
  description = "The number of elasticache snapshots to retain, only works for redis"
  default = "0"
}
