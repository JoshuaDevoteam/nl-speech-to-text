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
}

resource "google_storage_bucket_iam_policy" "default" {
  bucket      = var.bucket
  policy_data = data.google_iam_policy.default.policy_data
}
