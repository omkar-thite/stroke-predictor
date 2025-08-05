variable "region" {
}

variable "vpc_id" {
}

variable "db_instance_name" { 
}

variable "db_tier" {
}

variable "data_disk_size" {
}

variable "data_disk_type" {
}

variable "db_username" {
}

variable "db_password" {
    description = "The password for the PostgreSQL database"
    type        = string
    sensitive   = true
}

variable "db_name" {
}

