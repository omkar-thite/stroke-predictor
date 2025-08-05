resource "google_storage_bucket_iam_member" "storage_object_viewer" {
  bucket = var.artifacts_bucket_name
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${var.function_service_account_email}"

  depends_on = [ google_storage_bucket.artifacts_bucket ]
}

resource "google_storage_bucket_iam_member" "storage_object_creator" {
  bucket = var.artifacts_bucket_name
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${var.function_service_account_email}"

  depends_on = [ google_storage_bucket.artifacts_bucket ]
}

