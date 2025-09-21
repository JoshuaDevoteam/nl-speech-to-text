module "labels_egress_allow" {
  for_each = var.egress_allow_range
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "fw"
  attributes = ["allow", "egress"]
  name       = each.key
  context    = module.this.context
}
module "labels_egress_deny" {
  for_each = var.egress_deny_range
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "fw"
  attributes = ["deny", "egress"]
  name       = each.key
  context    = module.this.context
}
module "labels_ingress_allow_tag" {
  for_each = var.ingress_allow_tag
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "fw"
  attributes = ["allow", "ing"]
  name       = each.key
  context    = module.this.context
}

#need to replicate module as the for_each goes over different maps with different each.key's.
module "labels_ingress_allow_range" {
  for_each = var.ingress_allow_range
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "fw"
  attributes = ["allow", "ing"]
  name       = each.key
  context    = module.this.context
}
#for egress, we cannot specify the destination with a tag. only ip range. target is the egressing instance.
#for egress, target tag the sending instance. Destination can only be IP range.
resource "google_compute_firewall" "egress_allow_range" {
  for_each    = var.egress_allow_range
  project     = var.project
  network     = var.network
  name        = module.labels_egress_allow[each.key].id
  description = each.value.description
  direction   = "EGRESS"
  dynamic "allow" {
    for_each = each.value.protocols
    content {
      protocol = allow.key
      ports    = allow.value == [] ? null : allow.value
    }
  }
  target_tags        = each.value.target_tags == [] ? null : each.value.target_tags
  destination_ranges = each.value.destination_ranges
  priority           = each.value.priority
  dynamic "log_config" {
    for_each = contains(["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA"], coalesce(each.value.logging_mode, var.default_logging_mode, " ")) ? [""] : []
    content {
      metadata = coalesce(each.value.logging_mode, var.default_logging_mode)
    }
  }
}

resource "google_compute_firewall" "egress_deny_range" {
  for_each    = var.egress_deny_range
  project     = var.project
  network     = var.network
  name        = module.labels_egress_deny[each.key].id
  description = each.value.description
  direction   = "EGRESS"
  dynamic "deny" {
    for_each = each.value.protocols
    content {
      protocol = deny.key
      ports    = deny.value == [] ? null : deny.value
    }
  }
  target_tags        = each.value.target_tags == [] ? null : each.value.target_tags
  destination_ranges = each.value.destination_ranges
  priority           = each.value.priority
  dynamic "log_config" {
    for_each = contains(["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA"], coalesce(each.value.logging_mode, var.default_logging_mode, " ")) ? [""] : []
    content {
      metadata = coalesce(each.value.logging_mode, var.default_logging_mode)
    }
  }
}

#for ingress, source tag is the sending, target tag the receiving instance
resource "google_compute_firewall" "ingress_allow_tag" {
  for_each    = var.ingress_allow_tag
  project     = var.project
  network     = var.network
  name        = module.labels_ingress_allow_tag[each.key].id
  description = each.value.description
  direction   = "INGRESS"
  dynamic "allow" {
    for_each = each.value.protocols
    content {
      protocol = allow.key
      ports    = allow.value == [] ? null : allow.value
    }
  }
  source_tags = each.value.source_tags
  target_tags = each.value.target_tags
  dynamic "log_config" {
    for_each = contains(["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA"], coalesce(each.value.logging_mode, var.default_logging_mode, " ")) ? [""] : []
    content {
      metadata = coalesce(each.value.logging_mode, var.default_logging_mode)
    }
  }
}

#for ingress, source ranges is the sending, target tag the receiving instance
resource "google_compute_firewall" "ingress_allow_range" {
  for_each    = var.ingress_allow_range
  project     = var.project
  network     = var.network
  name        = module.labels_ingress_allow_range[each.key].id
  description = each.value.description
  direction   = "INGRESS"
  dynamic "allow" {
    for_each = each.value.protocols
    content {
      protocol = allow.key
      ports    = allow.value == [] ? null : allow.value
    }
  }
  target_tags   = each.value.target_tags
  source_ranges = each.value.source_ranges
  dynamic "log_config" {
    for_each = contains(["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA"], coalesce(each.value.logging_mode, var.default_logging_mode, " ")) ? [""] : []
    content {
      metadata = coalesce(each.value.logging_mode, var.default_logging_mode)
    }
  }
}
