# this module can be required to modify a google-created peering, for example when you need to export custom routes on
# the peering created by PSA, to import GCVE routes (sample use case), and you cannot control it at creation time.
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = var.peering
  network              = var.network
  project              = var.project
  import_custom_routes = var.import_custom_routes
  export_custom_routes = var.export_custom_routes
}
