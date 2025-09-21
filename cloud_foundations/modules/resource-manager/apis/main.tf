/***************************
  ENABLE APIS IN A PROJECT
***************************/
resource "google_project_service" "api" {
  for_each = var.services
  project  = var.project_id
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = var.disable_on_destroy
}
