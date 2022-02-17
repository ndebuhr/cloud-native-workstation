provider "google-beta" {}

data "google_project" "project" {}

resource "google_container_cluster" "primary" {
  provider                 = google-beta
  name                     = var.gke_cluster_name
  project                  = data.google_project.project.number
  location                 = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  resource_labels          = var.gcp_labels
  vertical_pod_autoscaling {
    enabled = true
  }
  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 8
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 4
      maximum       = 32
    }
    auto_provisioning_defaults {
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only"
      ]
    }
  }
  network_policy {
    enabled = true
  }
}

resource "google_container_node_pool" "primary_core" {
  provider   = google-beta
  name       = "core"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-custom-2-2048"
    disk_size_gb = 64
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    workload_metadata_config {
      mode = "MODE_UNSPECIFIED"
    }
  }
}
