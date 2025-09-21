module "hub_name" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  context          = module.this.context
  namespace        = "ncc-hub"
  label_key_case   = "lower" # label keys have to be lower case
  label_value_case = "lower" # label values have to be lower case
  labels_as_tags   = var.labels_as_tags
}

resource "google_network_connectivity_hub" "hub" {
  name        = module.hub_name.id
  description = coalesce(var.hub_description, module.hub_name.id)
  project     = var.project

  labels = module.hub_name.tags
}

module "spoke_names" {
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  for_each = var.spokes

  context          = module.this.context
  namespace        = "ncc-spoke"
  name             = each.key
  label_key_case   = "lower" # label keys have to be lower case
  label_value_case = "lower" # label values have to be lower case
  labels_as_tags   = var.labels_as_tags
}

resource "google_network_connectivity_spoke" "spokes" {
  for_each = var.spokes

  hub         = google_network_connectivity_hub.hub.id
  location    = each.value.location
  description = coalesce(each.value.description, module.spoke_names[each.key].id)
  name        = module.spoke_names[each.key].id
  labels      = module.spoke_names[each.key].tags
  project     = coalesce(each.value.project, var.project)

  dynamic "linked_vpc_network" {
    for_each = each.value.linked_vpc_network[*]
    content {
      exclude_export_ranges = linked_vpc_network.value.exclude_export_ranges
      uri                   = linked_vpc_network.value.uri
    }
  }

  dynamic "linked_interconnect_attachments" {
    for_each = each.value.linked_interconnect_attachments[*]
    content {
      site_to_site_data_transfer = linked_interconnect_attachments.value.site_to_site_data_transfer
      uris                       = linked_interconnect_attachments.value.uris
    }
  }

  dynamic "linked_router_appliance_instances" {
    for_each = each.value.linked_router_appliance_instances[*]
    content {
      site_to_site_data_transfer = linked_router_appliance_instances.value.site_to_site_data_transfer
      dynamic "instances" {
        for_each = linked_router_appliance_instances.value.instances
        content {
          ip_address      = instances.value.ip_address
          virtual_machine = instances.value.vm
        }
      }
    }
  }

  dynamic "linked_vpn_tunnels" {
    for_each = each.value.linked_vpn_tunnels[*]
    content {
      site_to_site_data_transfer = linked_vpn_tunnels.value.site_to_site_data_transfer
      uris                       = linked_vpn_tunnels.value.uris
    }
  }
}
