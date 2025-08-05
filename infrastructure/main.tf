terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.42.0"
    }
  }
  
  required_version = "1.12.2"
  backend "gcs" {
    bucket = # Enter your state bucket name here as string
    prefix = "terraform/state"  # This creates the path
    }
}


provider "google" {
  project = var.project_id
  region  = var.gcp_region
  zone    = var.zone

  impersonate_service_account =  var.impersonate_service_account
}


# Get current project information
data "google_client_config" "current" {}


locals {
  project_id = data.google_client_config.current.project
  region = data.google_client_config.current.region
}


module "gcs_bucket" {
  source = "./modules/gcs"
  project_id = var.project_id
  artifacts_bucket_name  = "prod_${var.artifacts_bucket_name}_${var.project_id}"
  function_service_account_email = var.function_service_account_email
}

module "artifact_registry" {
  source = "./modules/artifact_registry"
  region = var.gcp_region
  project_id = var.project_id
  
  artifacts_registry_repo_name = "${var.artifacts_registry_repo_name}-${var.project_id}"

  docker_yml_path = var.docker_yml_path
  dockerfile_inference_path = var.dockerfile_inference_path
  dockerfile_train_path = var.dockerfile_train_path

  train_script_path = var.train_script_path
  inference_script_path = var.inference_script_path

  inference_input_data_path = var.inference_input_data_path
  train_data_path = var.train_data_path

  image_name = var.image_name
  image_tag = var.image_tag
  state_bucket = var.state_bucket
  function_service_account_email = var.function_service_account_email
}

module "postgresql" {
  source = "./modules/postgresql"
  region = var.gcp_region

  db_instance_name = var.db_instance_name
  db_username  = var.db_username
  db_password  = var.db_password
  db_name = var.db_name
  db_tier = var.db_tier

  data_disk_size = var.data_disk_size
  data_disk_type = var.data_disk_type
  
  vpc_id = module.networking.vpc_id

  depends_on = [ module.networking ]
}


module "networking" {
  source = "./modules/networking"
  project_id = var.project_id
  region = var.gcp_region
  subnet_name = var.subnet_name
  subnet_cidr = var.subnet_cidr
  vpc_name = var.vpc_name
  connector_ip_cidr = var.connector_ip_cidr
  function_service_account_email = var.function_service_account_email
}

module "training_cloud_run_job" {
  source = "./modules/cloud_run_job"
  job_name = "${var.job_name}-training"
  project_id = var.project_id
  region = var.gcp_region
  image_uri = module.artifact_registry.train_image_uri
  job_type = "training"
  postgresql_private_ip = module.postgresql.private_ip_address

  db_username = var.db_username
  db_password = var.db_password
  db_name = var.db_name
  artifacts_bucket_name = module.gcs_bucket.name

  connector_id = module.networking.connector_id
}

module "inference_cloud_run_job" {
  source = "./modules/cloud_run_job"
  job_name = "${var.job_name}-inference"
  project_id = var.project_id
  region = var.gcp_region
  image_uri = module.artifact_registry.inference_image_uri
  job_type = "inference"
  postgresql_private_ip = module.postgresql.private_ip_address

  db_username = var.db_username
  db_password = var.db_password
  db_name = var.db_name
  artifacts_bucket_name = module.gcs_bucket.name

  connector_id = module.networking.connector_id

}

output "mlflow_tracking_uri" {
  value = module.postgresql.mlflow_tracking_uri
  sensitive = true
}

output "artifacts_bucket" {
  value = module.gcs_bucket.name
}

output "artifacts_registry_repo" {
  value = "${var.artifacts_registry_repo_name}-${var.project_id}"
}

output "inference-job-name" {
  value = "${var.job_name}-inference"
}

output "train-job-name" {
  value = "${var.job_name}-training"
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.gcp_region
}
