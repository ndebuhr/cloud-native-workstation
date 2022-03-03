variable "compute_zone" {
  description = "Google Cloud Platform zone, in which to run the workstation"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Name to give the provisioned Kubernetes cluster"
  type        = string
  default     = "cloud-native-workstation"
}

variable "spot" {
  description = "Use of spot VM instances"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Resource labels to add to GCE node machines"
  type        = map(string)
  default = {
    "purpose" = "cloud_systems_solutioning"
  }
}