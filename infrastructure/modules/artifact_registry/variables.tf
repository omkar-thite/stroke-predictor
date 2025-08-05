variable "artifacts_registry_repo_name" {
  description = "Artifacts Repostiory to store docker images"
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}


variable "docker_yml_path" {
  description = "Local path to Dockerfile"
  type = string
}

variable "region" {
  description = "Docker repository region"
}

variable "image_name" {
  description = "Docker image name"
}

variable "image_tag" {
  description = "Docker image tag"
}

variable "state_bucket" {
}

variable "function_service_account_email" { 
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
