resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  project                  = data.google_project.project.number
  location                 = var.compute_zone
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  resource_labels          = var.labels
  network_policy {
    enabled = true
  }
}

resource "google_container_node_pool" "primary_core" {
  name       = "core"
  location   = var.compute_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }
  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-standard-8"
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

resource "google_container_node_pool" "primary_gpu" {
  count      = var.gpu.enabled ? 1 : 0
  name       = "gpu-enabled"
  location   = var.compute_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "n1-standard-4"
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
    guest_accelerator {
      type  = var.gpu.type
      count = var.gpu.count
    }
  }
}