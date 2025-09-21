data "google_iam_policy" "default" {
  dynamic "binding" {
    for_each = var.bindings

    content {
      role    = binding.key
      members = binding.value
    }
  }

  dynamic "binding" {
    for_each = var.conditional_bindings

    content {
      role    = binding.value.role
      members = binding.value.members
      condition {
        expression  = binding.value.condition
        title       = binding.value.title
        description = binding.value.description
      }
    }
  }

  dynamic "audit_config" {
    for_each = var.service_audit_configs

    content {
      service = audit_config.key
      dynamic "audit_log_configs" {
        for_each = toset(audit_config.value)

        content {
          log_type         = audit_log_configs.value.log_type
          exempted_members = audit_log_configs.value.exempted_members
        }
      }
    }
  }
}

resource "google_organization_iam_policy" "default" {
  org_id      = var.org_id
  policy_data = data.google_iam_policy.default.policy_data
}
