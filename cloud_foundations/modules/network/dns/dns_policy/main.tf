module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  context   = module.this.context
  namespace = "dnspo"
}

resource "google_dns_policy" "policy" {
  project                   = var.project
  name                      = module.label.id
  description               = var.description
  enable_inbound_forwarding = var.enable_inbound_forwarding
  enable_logging            = var.logging

  dynamic "alternative_name_server_config" {
    for_each = length(var.target_name_servers) > 0 ? [""] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "networks" {
    for_each = toset(var.networks)
    content {
      network_url = networks.value
    }
  }
}
