variable "environment" {
  description = "The platform environment"
}

variable "name_prefix" {
  description = "The prefix used to disambiguate names between different environments on the same account"
}

variable "name" {
  description = "The component name"
}

variable "aws_region" {
  description = "The aws region"
}

variable "app_port" {
  description = "The port for the app server inside the container"
}

variable "instance_port" {
  description = "The port for the app server hit by the load balancer"
}

variable "integrate_with_elb" {
  description = "Integrate service with ELB"
  default = 1
}

variable "elb_id" {
  description = "The ELB id to load balance the service with"
}

variable "containers_template" {
  description = "The template for the containers in the task definition"
}

variable "ecs_cluster_id" {
  description = "The ECS cluster to deploy containers into"
}

variable "app_container_count" {
  description = "The desired count of app containers"
  default = 2
}
