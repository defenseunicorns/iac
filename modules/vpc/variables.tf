variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "name" {
  description = "Name to be used on all resources as identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones to deploy into"
  type        = list(string)
}

variable "private_subnet_tags" {
  description = "Tags to apply to private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Tags to apply to public subnets"
  type        = map(string)
  default     = {}
}

variable "create_database_subnet_group" {
  description = "Create database subnet group"
  type        = bool
  default     = true
}

variable "create_database_subnet_route_table" {
  description = "Create database subnet route table"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Tenancy of instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "public_subnets" {
  description = "List of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "List of database subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Control whether an instance will receive a public IP address by default."
  type        = bool
  default     = false
}

variable "default_acl_rules" {
  description = "Subnets network ACLs. Only allows port 22 from 10.0.0.0/24 network"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "22"
      cidr_block  = "10.0.0.0/24"
    },
  ]
}
