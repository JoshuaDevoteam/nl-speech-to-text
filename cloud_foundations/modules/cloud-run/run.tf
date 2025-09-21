resource "google_cloud_run_v2_service" "service" {
  project  = var.project
  name     = var.name
  location = var.location

  template {
    annotations = local.all_annotations
    labels = {
      "run.googleapis.com/startupProbeType" = "Default"
    }
    service_account = var.service_account_email
    timeout         = var.timeout
    containers {
      image = var.container_image
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }
      dynamic "env" {
        for_each = local.env_vars

        content {
          name  = env.key
          value = lookup(env.value, "value", null) != null ? env.value.value : null
          dynamic "value_source" {
            for_each = lookup(env.value, "secret_key_ref", null) != null ? [1] : []

            content {
              secret_key_ref {
                secret  = env.value.secret_key_ref.name
                version = env.value.secret_key_ref.key
              }
            }
          }
        }
      }

      ports {
        container_port = var.port
      }

    }
  }

  traffic {
    type     = var.traffic.type
    percent  = var.traffic.percent
    revision = var.traffic.revision
    tag      = var.traffic.tag
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].labels["run.googleapis.com/client-name"],
      template[0].labels["run.googleapis.com/client-version"],
      template[0].labels["client.knative.dev/nonce"],
      template[0].labels["run.googleapis.com/startupProbeType"],
    ]
  }
}