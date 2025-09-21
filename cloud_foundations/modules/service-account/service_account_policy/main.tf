data "google_iam_policy" "iam_policy" {
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
}

resource "google_service_account_iam_policy" "sa_iam_policy" {
  service_account_id = var.service_account_id
  policy_data        = data.google_iam_policy.iam_policy.policy_data
}
