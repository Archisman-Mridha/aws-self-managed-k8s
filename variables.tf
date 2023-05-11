variable "project_name" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_vpc_cidr" {
  type        = string
  description = "AWS VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "aws_zones" {
  type        = list(string)
  description = "Availability zones in the current AWS region. In each zone, a public and private subnet will be created."
}

variable "aws_instance_type" {
  type        = string
  description = "Default AWS EC2 instance type"
  default     = "t2.medium"
}
