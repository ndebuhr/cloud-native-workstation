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

variable "gpu" {
  description = "GPU profile"
  type = object({
    enabled = bool
    type    = string
    count   = number
  })
  default = {
    enabled = true
    type    = "nvidia-tesla-t4"
    count   = 1
  }
}

variable "labels" {
  description = "Resource labels to add to GCE node machines"
  type        = map(string)
  default = {
    "purpose" = "cloud_systems_solutioning"
  }
}