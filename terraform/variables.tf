variable "gcp_project" {
  description = "ID of the target project on Google Cloud Platform"
  default = "my-project"
}

variable "gcp_service_account_key_filepath" {
  description = "Location of the Google Cloud Platform service account key file, for use in provisioning the infrastructure.  This account must have sufficient Compute Engine, Kubernetes Engine, and Storage (for Google Container Registry) permissions."
  default = "/home/me/gcp/key.json"
}

variable "gcp_zone" {
  description = "Google Cloud Platform zone to run the devtools"
  default = "us-central1-a"
}

variable "gke_cluster_name" {
  description = "Name to give the provisioned Kubernetes cluster containing the devtools"
  default = "cloud-native-workstation"
}

