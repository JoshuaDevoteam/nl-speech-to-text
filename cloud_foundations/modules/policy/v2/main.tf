resource "google_org_policy_policy" "policy" {
  name   = local.name
  parent = local.parent


  # TODO: add parameters
  # TODO: add condition
  spec {
    # Block for when it is a boolean policy
    dynamic "rules" {
      for_each = coalesce(var.restore_policy, false) ? [] : var.boolean_policy[*]
      content {
        enforce = rules.value ? "TRUE" : "FALSE"
      }
    }
    # Block for when it is a list policy
    dynamic "rules" {
      for_each = coalesce(var.restore_policy, false) ? [] : var.list_policy[*]
      content {
        deny_all  = coalesce(try(rules.value.deny.all, false), false) ? "TRUE" : null
        allow_all = coalesce(try(rules.value.allow.all, false), false) ? "TRUE" : null
        dynamic "values" {
          for_each = length(coalesce(try(rules.value.allow.values, []), [])) + length(coalesce(try(rules.value.deny.values, []), [])) > 0 ? [""] : []
          content {
            allowed_values = try(rules.value.allow.values, null)
            denied_values  = try(rules.value.deny.values, null)
          }
        }
      }
    }

    inherit_from_parent = coalesce(var.restore_policy, false) || var.boolean_policy != null ? false : var.inherit_from_parent
    reset               = var.restore_policy
  }
}
