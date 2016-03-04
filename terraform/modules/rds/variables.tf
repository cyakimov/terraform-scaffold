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

variable "db_instance_type" {
  description = "The instance type for the database instance"
  default = "db.m3.medium"
}

variable "db_instance_storage" {
  description = "The allocated storage for the database instance"
  default = 10
}

variable "db_instance_storage_type" {
  description = "The storage type for the database instance"
  default = "gp2"
}

variable "db_name" {
  description = "The name of the database"
  default = "postgres"
}

variable "db_username" {
  description = "The username for the database"
  default = "postgres"
}

variable "db_password" {
  description = "The username for the database"
  default = "postgres"
}

variable "encrypted" {
  description = "Turn on database encryption"
  default = false
}
