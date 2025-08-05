variable "job_name" {
}

variable "region" {
}

variable "image_uri" {
}

variable "project_id" {
}

variable "job_type" {
  description = "Type of job (training or inference)"
  default = "training"
}

variable "postgresql_private_ip" {
}

variable "db_username" {
}

variable "db_password" {
  sensitive = true
}

variable "db_name" {
}

variable "artifacts_bucket_name" {
}

variable "connector_id" {
}

