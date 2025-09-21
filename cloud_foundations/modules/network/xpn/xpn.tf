# A host project provides network resources to associated service projects.
resource "google_compute_shared_vpc_host_project" "host" {
  //only enable if there is service projects
  count   = length(var.service_projects) != 0 ? 1 : 0
  project = var.host_project
}

# A service project gains access to network resources provided by its
# associated host project.
resource "google_compute_shared_vpc_service_project" "service" {
  for_each        = toset(var.service_projects)
  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = each.key
}
