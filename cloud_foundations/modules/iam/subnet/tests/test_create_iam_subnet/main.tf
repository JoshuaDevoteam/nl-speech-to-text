data "google_iam_policy" "default" {
  dynamic "binding" {
    for_each = var.bindings

    content {
      role    = binding.key
      members = binding.value
    }
  }
}

resource "google_compute_subnetwork_iam_policy" "policy" {
  project     = var.subnet_project_id
  region      = var.subnet_region
  subnetwork  = var.subnet_name
  policy_data = data.google_iam_policy.default.policy_data
}
