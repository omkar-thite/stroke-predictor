resource "google_artifact_registry_repository_iam_member" "repo_iam" {
  repository = google_artifact_registry_repository.docker-repository.name
  location   = var.region
  project    = var.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.function_service_account_email}"
}