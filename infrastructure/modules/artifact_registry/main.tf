resource "google_artifact_registry_repository" "docker-repository" {
  location      = var.region
  repository_id = var.artifacts_registry_repo_name
  description   = "Docker repo to store images for cloud services."
  format        = "DOCKER"
}


resource "terraform_data" "registry_docker_image" {
  triggers_replace = [
    md5(file(var.docker_yml_path)),
    md5(file(var.dockerfile_train_path)),
    md5(file(var.dockerfile_inference_path)),
    md5(file(var.train_script_path)),
    md5(file(var.inference_script_path)),
    md5(file(var.inference_input_data_path)),
    md5(file(var.train_data_path))
  ]

  provisioner "local-exec" {
    command = <<EOF
             gcloud auth configure-docker ${var.region}-docker.pkg.dev

             # Build train service
             docker compose -f ${var.docker_yml_path} build train
             docker tag train:latest ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/train:${var.image_tag}
             docker push ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/train:${var.image_tag}

             # Build inference service
             docker compose -f ${var.docker_yml_path} build inference
             docker tag inference:latest ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/inference:${var.image_tag}
             docker push ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/inference:${var.image_tag}
         EOF
  }
}


data "google_artifact_registry_docker_image" "train_image" {
  depends_on = [ terraform_data.registry_docker_image ]
  location      = google_artifact_registry_repository.docker-repository.location   // location = terraform_artifact_registry_type.repo_name.location
  repository_id = google_artifact_registry_repository.docker-repository.repository_id
  image_name    = "train:${var.image_tag}"
}

data "google_artifact_registry_docker_image" "inference_image" {
  depends_on = [ terraform_data.registry_docker_image ]
  location      = google_artifact_registry_repository.docker-repository.location   // location = terraform_artifact_registry_type.repo_name.location
  repository_id = google_artifact_registry_repository.docker-repository.repository_id
  image_name    = "inference:${var.image_tag}"
}

output "train_image_uri" {
  // value = "${google_artifact_registry_repository.docker-repository.location}"-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/${var.image_name}:${var.image_tag}"
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/train:${var.image_tag}"
}

output "inference_image_uri" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker-repository.repository_id}/inference:${var.image_tag}"
}

output "repository_id" {
  value = google_artifact_registry_repository.docker-repository.repository_id
}