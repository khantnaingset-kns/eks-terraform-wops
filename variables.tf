variable "region" {
  type = string
  description = "AWS Region"
}

variable "cluster_name" {
  type = string
  description = "Name of the Cluster"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type = list(string)
  description = "ID of the Subnets"
}

variable "control_plane_subnet_ids" {
  type = list(string)
  description = "ID of the Control Plane Subnets"
}

