module "psa_name" {
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  for_each = local.addresses_to_reserve

  namespace   = "psa"
  attributes  = each.value.attributes
  context     = module.this.context
  label_order = ["namespace", "environment", "name", "attributes"]
}

resource "google_compute_global_address" "private_ip_alloc" {
  for_each = local.addresses_to_reserve

  project       = var.project
  network       = var.network
  name          = module.psa_name[each.key].id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value.range)[0]
  prefix_length = split("/", each.value.range)[1]
}

resource "google_service_networking_connection" "google_psa" {
  for_each = var.private_service_access

  network                 = var.network
  service                 = each.value.service
  reserved_peering_ranges = [for key, range in each.value.cidr_ranges : google_compute_global_address.private_ip_alloc["${each.key}-${key}"].name]
}
