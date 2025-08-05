resource "google_compute_network" "vpc_network" {
  name = var.vpc_name
  project = var.project_id
  auto_create_subnetworks = false

  depends_on = [ google_project_iam_member.network_admin ]
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region       = var.region
  network      = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_postgresql" {
  name    = "allow-postgresql"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.subnet_cidr, var.connector_ip_cidr]
  target_tags = ["sql-instance"]

}

resource "google_vpc_access_connector" "connector" {
  name          = "vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.connector_ip_cidr  # This range must not overlap with your VPC
  max_instances = 3
  min_instances = 2
  machine_type  = "e2-micro" 

  depends_on = [ google_compute_network.vpc_network,
                  google_compute_subnetwork.subnetwork 
                ]
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# Reserve a global IP range for private service connections
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

# Create a private connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnetwork.id
}

output "connector_id" {
  value = google_vpc_access_connector.connector.id
}

output "private_connection_id" {
  value = google_service_networking_connection.private_vpc_connection.id
}