resource "google_cloudbuild_trigger" "default" {
  project         = var.project
  name            = var.trigger_name
  substitutions   = var.substitutions
  filename        = var.config_path
  included_files  = var.included_files
  ignored_files   = var.ignored_files
  disabled        = var.disabled
  description     = var.description
  service_account = var.service_account

  dynamic "github" {
    for_each = var.repo_type == "GITHUB" ? [var.repo_type] : []
    content {
      owner = var.repo_owner
      name  = var.repo_name
      dynamic "push" {
        for_each = var.on == "PUSH_TAG" || var.on == "PUSH_BRANCH" ? [
          var.on
        ] : []
        content {
          tag          = var.on == "PUSH_TAG" ? var.regex : null
          branch       = var.on == "PUSH_BRANCH" ? var.regex : null
          invert_regex = var.invert_regex
        }
      }

      dynamic "pull_request" {
        for_each = var.on == "PULL_REQUEST" ? [
          var.on
        ] : []
        content {
          branch          = var.regex
          invert_regex    = var.invert_regex
          comment_control = var.pull_request_comment_control
        }
      }
    }
  }
}