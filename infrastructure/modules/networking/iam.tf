
resource "google_project_iam_member" "network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${var.function_service_account_email}"
}

resource "google_project_iam_member" "sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.function_service_account_email}"
}

# Add this resource to grant the necessary firewall permissions
resource "google_project_iam_member" "security_admin" {
  project = var.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${var.function_service_account_email}"

  # Add this to avoid race conditions
  depends_on = [ google_project_iam_member.network_admin ]
}