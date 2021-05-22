variable "gcp_project" {
  description = "ID of the target project on Google Cloud Platform"
  default = "my-project"
  sensitive = true
}

variable "gcp_zone" {
  description = "Google Cloud Platform zone to run the devtools"
  default = "us-central1-a"
}

variable "gke_cluster_name" {
  description = "Name to give the provisioned Kubernetes cluster containing the devtools"
  default = "cloud-native-workstation"
}
