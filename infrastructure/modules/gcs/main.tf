resource "google_storage_bucket" "artifacts_bucket" {
    name = var.artifacts_bucket_name
    location = "ASIA-SOUTH1" 

    project = var.project_id
    force_destroy = true
    uniform_bucket_level_access = true
    public_access_prevention = "enforced"
}

output "name" {
  value = google_storage_bucket.artifacts_bucket.id
}

output "mlflow_artifacts_root" {
  value = "gs://${google_storage_bucket.artifacts_bucket.name}/mlartifacts"  
}