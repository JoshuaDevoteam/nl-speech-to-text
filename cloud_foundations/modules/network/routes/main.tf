module "labels_route" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  namespace = "rt"
  context   = module.this.context
}

resource "google_compute_route" "route" {
  project                = var.project
  name                   = module.labels_route.id
  network                = var.network
  description            = var.description
  dest_range             = var.dest_range
  priority               = var.priority
  tags                   = var.instance_tags
  next_hop_gateway       = var.next_hop_gateway
  next_hop_instance      = var.next_hop_instance
  next_hop_ip            = var.next_hop_ip
  next_hop_vpn_tunnel    = var.next_hop_vpn_tunnel
  next_hop_ilb           = var.next_hop_ilb
  next_hop_instance_zone = var.next_hop_instance_zone
}
