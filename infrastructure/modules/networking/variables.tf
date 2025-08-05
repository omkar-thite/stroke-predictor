variable "project_id" {
  
}

variable "region" {
  
}

variable "vpc_name" {
  description = "The name of the VPC to create."
  type        = string
}

variable "subnet_name" {
}

variable "subnet_cidr" { 
}

variable "function_service_account_email" {
}

variable "connector_ip_cidr" {
}
