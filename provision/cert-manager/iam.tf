data "google_project" "project" {}

resource "google_service_account" "cert_manager" {
  account_id   = "workstation-cert-manager"
  display_name = "Workstation Cert Manager"
}

resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = data.google_project.project.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}

resource "google_project_iam_member" "cert_manager_workload_identity_user" {
  project = data.google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[kube-system/workstation-prerequisites-cert-manager]"
}