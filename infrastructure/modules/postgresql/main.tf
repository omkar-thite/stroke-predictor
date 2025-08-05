resource "google_sql_database_instance" "postgres_instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
        # Second-generation instance tiers are based on the machine
        # type. See argument reference below.
        tier = var.db_tier
        
        ip_configuration {
        ipv4_enabled = false
        private_network = var.vpc_id
        }

        user_labels = {
          "tag" = "sql-instance"
      }

    }
    deletion_protection = false
}

resource "google_sql_user" "default_user" {
  name     = var.db_username
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

resource "google_sql_database" "default_database" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}


output "instance_connection_name" {
  value = google_sql_database_instance.postgres_instance.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}

output "mlflow_tracking_uri" {
  value = "postgresql://${var.db_username}:${var.db_password}@${google_sql_database_instance.postgres_instance.private_ip_address}:5432/${var.db_name}"
  sensitive = true
}
