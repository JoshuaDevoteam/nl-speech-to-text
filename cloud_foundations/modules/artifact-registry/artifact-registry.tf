resource "google_artifact_registry_repository" "repository" {
  project       = var.project_id
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository_id
  format        = var.artifact_registry_format
  description   = var.artifact_registry_description

  dynamic "docker_config" {
    for_each = var.docker_config != null ? [var.docker_config] : []
    content {
      immutable_tags = lookup(docker_config.value, "immutable_tags", null)
    }
  }

  # Note: cleanup_policies requires Google provider >= 5.0.0
  # Commented out for compatibility with provider 4.78.0
  # To enable, upgrade the provider version in version.tf
  # dynamic "cleanup_policies" {
  #   for_each = var.cleanup_policies
  #
  #   content {
  #     id     = cleanup_policies.value.id
  #     action = cleanup_policies.value.action
  #
  #     # A nested dynamic block for the optional 'condition'
  #     dynamic "condition" {
  #       for_each = lookup(cleanup_policies.value, "condition", null) != null ? [cleanup_policies.value.condition] : []
  #       content {
  #         tag_state             = lookup(condition.value, "tag_state", null)
  #         tag_prefixes          = lookup(condition.value, "tag_prefixes", null)
  #         version_name_prefixes = lookup(condition.value, "version_name_prefixes", null)
  #         older_than            = lookup(condition.value, "older_than", null)
  #         newer_than            = lookup(condition.value, "newer_than", null)
  #       }
  #     }
  #
  #     # A nested dynamic block for the optional 'most_recent_versions'
  #     dynamic "most_recent_versions" {
  #       for_each = lookup(cleanup_policies.value, "most_recent_versions", null) != null ? [cleanup_policies.value.most_recent_versions] : []
  #       content {
  #         package_name_prefixes = lookup(most_recent_versions.value, "package_name_prefixes", null)
  #         keep_count            = lookup(most_recent_versions.value, "keep_count", null)
  #       }
  #     }
  #   }
  # }
}
