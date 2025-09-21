data "google_iam_policy" "default" {
  dynamic "binding" {
    for_each = var.bindings

    content {
      role    = binding.key
      members = binding.value
    }
  }
}

resource "google_storage_bucket_iam_policy" "default" {
  bucket      = var.bucket
  policy_data = data.google_iam_policy.default.policy_data
}
