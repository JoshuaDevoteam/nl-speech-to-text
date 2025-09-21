resource "google_compute_router" "router" {
  name        = module.router_name.id
  description = var.description == null ? module.router_name.id : var.description
  network     = var.network
  region      = var.region
  project     = var.project
  bgp {
    asn                = var.asn
    advertise_mode     = "CUSTOM"
    advertised_groups  = var.advertise_subnets ? ["ALL_SUBNETS"] : []
    keepalive_interval = var.keepalive_interval

    dynamic "advertised_ip_ranges" {
      for_each = var.advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}

resource "google_compute_interconnect_attachment" "attachment" {
  for_each = var.attachments

  name                     = module.attachment_name[each.key].id
  description              = each.value.description == null ? module.attachment_name[each.key].id : each.value.description
  router                   = google_compute_router.router.id
  project                  = google_compute_router.router.project
  region                   = google_compute_router.router.region
  edge_availability_domain = each.value.edge_availability_domain
  mtu                      = each.value.mtu
  type                     = "PARTNER"
  admin_enabled            = each.value.enabled
}


# The following resources will only be created once 'activated' is set to true. Activation will have happened manually,
# meaning these resources will have to be imported. Be careful to make sure your Terraform code reflects the actual
# config before making changes. Deleting one of these resources can mean that they will have to be reactivated.
resource "google_compute_router_interface" "interface" {
  for_each = { for key, attachment in var.attachments : key => attachment if attachment.activated }

  # The name will look something like this: auto-ia-if-...
  name                    = each.value.override_names ? each.value.router_interface_name : module.interface_name[each.key].id
  project                 = google_compute_router.router.project
  region                  = google_compute_router.router.region
  router                  = google_compute_router.router.name
  interconnect_attachment = google_compute_interconnect_attachment.attachment[each.key].self_link
  ip_range                = each.value.ip_range
}

resource "google_compute_router_peer" "peer" {
  for_each = { for key, attachment in var.attachments : key => attachment if attachment.activated }

  # The name will look something like this: auto-ia-bgp-...
  name                      = each.value.override_names ? each.value.router_peer_name : module.peer_name[each.key].id
  enable                    = each.value.enabled
  project                   = google_compute_router.router.project
  region                    = google_compute_router.router.region
  router                    = google_compute_router.router.name
  interface                 = google_compute_router_interface.interface[each.key].name
  peer_ip_address           = each.value.peer_ip_address
  peer_asn                  = each.value.peer_asn
  advertised_route_priority = each.value.priority
  advertise_mode            = each.value.advertise_mode
  advertised_groups         = each.value.advertised_groups == null ? [] : each.value.advertised_groups

  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges != null ? each.value.advertised_ip_ranges : []
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }

  dynamic "bfd" {
    for_each = each.value.bfd == null ? [{}] : [each.value.bfd]
    content {
      session_initialization_mode = lookup(bfd.value, "session_initialization_mode", "DISABLED")
      min_receive_interval        = lookup(bfd.value, "min_receive_interval", 1000)
      min_transmit_interval       = lookup(bfd.value, "min_transmit_interval", 1000)
      multiplier                  = lookup(bfd.value, "multiplier", 5)
    }
  }
}
