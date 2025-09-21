module "labels_peering" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  namespace = "nwp"
  context   = module.this.context
}

resource "google_compute_network_peering" "peering_left" {
  name                 = module.labels_peering.id
  network              = var.network
  peer_network         = var.peer_network
  export_custom_routes = var.exchange_network_routes
  import_custom_routes = var.exchange_peer_network_routes
}
resource "google_compute_network_peering" "peering_right" {
  name                 = module.labels_peering.id
  network              = var.peer_network
  peer_network         = var.network
  export_custom_routes = var.exchange_peer_network_routes
  import_custom_routes = var.exchange_network_routes
}
