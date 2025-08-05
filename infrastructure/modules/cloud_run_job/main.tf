resource "google_cloud_run_v2_job" "cloud_run_job" {
  name     = var.job_name
  location = var.region
  deletion_protection = false

  template {
    template {
      containers {
        image = var.image_uri

        # Add environment variable for artifact bucket
        env {
          name = "ARTIFACTS_BUCKET_NAME"
          value = var.artifacts_bucket_name
        }

        env {
          name = "JOB_TYPE"
          value = var.job_type
        }

        env {
          name  = "DB_HOST"
          value = var.postgresql_private_ip
        }
        
        env {
          name  = "DB_PORT"
          value = "5432"
        }

        # Add MLflow tracking URI environment variable
        env {
          name  = "MLFLOW_TRACKING_URI"
          value = "postgresql://${var.db_username}:${var.db_password}@${var.postgresql_private_ip}:5432/${var.db_name}"
        }

        # Add MLflow artifact root environment variable
        env {
          name  = "MLFLOW_ARTIFACT_ROOT"
          value = "gs://${var.artifacts_bucket_name}/mlartifacts"
        }
      
      }

    vpc_access {
      connector = var.connector_id
      egress = "PRIVATE_RANGES_ONLY"
    }  
  
  }
  
}
}


# This resource will be triggered by terraform apply
resource "terraform_data" "run_cloud_job" {
  depends_on = [google_cloud_run_v2_job.cloud_run_job]
  
  # Only execute the job if specifically requested via an environment variable
  triggers_replace = {
    run_job = terraform.workspace
  }

  provisioner "local-exec" {
    command = "if [ \"$EXECUTE_JOB_TYPE\" = \"${var.job_type}\" ]; then gcloud run jobs execute ${var.job_name} --region ${var.region} --project ${var.project_id}; fi"
  }
}