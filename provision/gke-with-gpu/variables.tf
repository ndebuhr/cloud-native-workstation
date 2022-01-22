variable "gcp_zone" {
  description = "Google Cloud Platform zone to run the devtools"
  default     = "us-central1-a"
}

variable "gke_cluster_name" {
  description = "Name to give the provisioned Kubernetes cluster containing the devtools"
  default     = "cloud-native-workstation"
}

variable "gcp_gpu" {
  description = "GCP name for the GPU to use"
  default     = "nvidia-tesla-t4"
}

variable "gcp_labels" {
  description = "Resource labels to add to GCE node machines"
  default = {
    "purpose" = "cloud_systems_solutioning"
  }
}