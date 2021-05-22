provider "google" {
  project     = var.gcp_project
}

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster_name
  project                  = var.gcp_project
  location                 = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_core" {
  name       = "core"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }
  node_config {
    machine_type = "n1-standard-8"
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}