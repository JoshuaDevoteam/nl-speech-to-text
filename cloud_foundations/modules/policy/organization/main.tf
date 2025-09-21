resource "google_organization_policy" "policy" {
  org_id     = var.org_id
  constraint = var.constraint

  dynamic "boolean_policy" {
    for_each = var.boolean_policy[*]
    content {
      enforced = boolean_policy.value
    }
  }

  dynamic "list_policy" {
    for_each = var.list_policy[*]
    content {
      dynamic "allow" {
        for_each = lookup(list_policy.value, "allow", null)[*]
        content {
          values = lookup(allow.value, "values", null)
          all    = lookup(allow.value, "all", null)
        }
      }

      dynamic "deny" {
        for_each = lookup(list_policy.value, "deny", null)[*]
        content {
          values = lookup(deny.value, "values", null)
          all    = lookup(deny.value, "all", null)
        }
      }
    }
  }
}
