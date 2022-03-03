terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "~> 4.12.0"
    }
  }
}

data "google_project" "project" {}

