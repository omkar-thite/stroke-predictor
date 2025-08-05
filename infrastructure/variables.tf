locals {
    tf-state-bucket-name = "tf-state-${var.project_id}"
}

variable "gcp_region" {
    description = "GCP Region to create resources."
}

variable "project_id" {
    description = "GCP project id"
}

variable "zone" {
    description = "Zone for GCP project"
}

variable "impersonate_service_account" {
  description = "Service account to imporsonte to run services."
}


variable "artifacts_bucket_name" {
  description = "GCS bucket name for artrifacts"
}

variable "artifacts_registry_repo_name" {
    description = "Artifacts Repostiory to store docker images"
}

variable "docker_yml_path" {
  description = "Local path to Dockerfile"
}

variable "image_name" {
  description = "Docker image name"
}

variable "image_tag" {
  description = "Docker image tag"
}

variable "function_service_account_email" {
}


variable "state_bucket" {
}

variable "job_name" {
}

variable "connector_ip_cidr" {
}

variable "vpc_name" {
}

variable "subnet_name" {
}

variable "subnet_cidr" {
}

variable "db_instance_name" {
}

variable "db_username" {
}

variable "db_password" {
}

variable "data_disk_size" {
}

variable "data_disk_type" {
}

variable "db_name" {
}

variable "db_tier" {
}

variable "dockerfile_inference_path" {
}

variable "dockerfile_train_path" {
}


variable "train_script_path" {
}

variable "inference_script_path" {
}

variable "inference_input_data_path" {
}

variable "train_data_path" {
}
