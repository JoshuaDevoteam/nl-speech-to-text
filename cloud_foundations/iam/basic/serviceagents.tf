data "google_client_config" "current" {}

data "google_project" "serviceagents_project" {
  for_each   = local.projects
  project_id = each.value.project_id
}

data "http" "serviceagents_service" {
  for_each = local.projects

  url = "https://serviceusage.googleapis.com/v1/projects/${data.google_project.serviceagents_project[each.key].number}/services?pageSize=200&filter=state:ENABLED"

  # Optional request headers
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
}

resource "google_project_service_identity" "serviceagents_service_account" {
  provider = google-beta
  for_each = local.serviceagents_service_accounts_resource

  project = each.value.project
  service = each.value.service
}
