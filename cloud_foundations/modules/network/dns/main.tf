module "label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  context          = module.this.context
  namespace        = "dns"
  label_key_case   = "lower" # https://cloud.google.com/sdk/gcloud/reference/dns/managed-zones/create#--labels
  label_value_case = "lower" # https://cloud.google.com/sdk/gcloud/reference/dns/managed-zones/create#--labels
}

#tfsec:ignore:google-dns-enable-dnssec
resource "google_dns_managed_zone" "dns_zone" {
  #checkov:skip=CKV_GCP_16: "Ensure that DNSSEC is enabled for Cloud DNS"
  provider       = google-beta
  project        = var.project
  dns_name       = var.dns_name
  name           = module.label.id
  description    = var.description == "" ? module.label.id : var.description
  labels         = module.label.tags
  visibility     = var.visibility
  reverse_lookup = var.reverse_lookup
  force_destroy  = var.force_destroy

  dynamic "dnssec_config" {
    for_each = var.visibility == "private" ? toset([]) : toset(["1"])
    content {
      kind          = var.dnssec_config.kind
      non_existence = var.dnssec_config.non_existence
      state         = var.dnssec_config.state

      dynamic "default_key_specs" {
        for_each = var.dnssec_config.default_key_specs == null ? toset([]) : toset(["1"])
        content {
          algorithm  = var.dnssec_config.default_key_specs.algorithm
          key_length = var.dnssec_config.default_key_specs.key_length
          key_type   = var.dnssec_config.default_key_specs.key_type
          kind       = var.dnssec_config.default_key_specs.kind
        }
      }
    }
  }

  dynamic "private_visibility_config" {
    for_each = var.private_visibility_config == null ? toset([]) : toset(["1"])
    content {
      dynamic "networks" {
        for_each = { for network in var.private_visibility_config.networks : network.network_url => network }
        content {
          network_url = networks.value["network_url"]
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = var.forwarding_config == null ? toset([]) : toset(["1"])
    content {
      dynamic "target_name_servers" {
        for_each = { for name_server in var.forwarding_config.target_name_servers : name_server.ipv4_address => name_server }
        content {
          ipv4_address    = target_name_servers.value["ipv4_address"]
          forwarding_path = target_name_servers.value["forwarding_path"]
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = var.peering_config == null ? toset([]) : toset(["1"])
    content {
      target_network {
        network_url = var.peering_config.target_network.network_url
      }
    }
  }

  dynamic "service_directory_config" {
    for_each = var.service_directory_config == null ? toset([]) : toset(["1"])
    content {
      namespace {
        namespace_url = var.service_directory_config.namespace.namespace_url
      }
    }
  }
}

resource "google_dns_record_set" "records" {
  for_each     = var.records
  provider     = google-beta
  project      = var.project
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = each.key
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}
