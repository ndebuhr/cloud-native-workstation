provider "google" {}

data "google_project" "project" {}

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster_name
  project                  = data.google_project.project.number
  location                 = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1
  network_policy {
    enabled = true
  }
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