resource "google_cloud_run_v2_job" "job" {
  project      = var.project_id
  name         = var.name
  location     = var.location
  launch_stage = var.launch_stage

  template {
    parallelism = var.parallelism
    task_count  = var.task_count
    template {
      containers {
        name    = var.container_name
        image   = var.container_image
        command = var.command
        args    = var.args
        dynamic "env" {
          for_each = local.env_vars

          content {
            name = env.key
            dynamic "value_source" {
              for_each = lookup(env.value, "secret_key_ref", null) != null ? [1] : []
              content {
                secret_key_ref {
                  secret  = env.value.secret_key_ref.name
                  version = env.value.secret_key_ref.key
                }
              }
            }
            value = lookup(env.value, "value", null)
          }
        }
        dynamic "resources" {
          for_each = var.cpu != null || var.memory != null ? [1] : []
          content {
            limits = {
              cpu    = var.cpu
              memory = var.memory
            }
          }
        }
        # ports {
        #   name = var.ports_name
        #   container_port = var.container_port
        # }
        # volume_mounts {
        #   name       = var.volume_mount_name
        #   mount_path = var.volume_mount_path
        # }
        working_dir = var.working_dir
      }
      # volumes {
      #   name = var.volume_name
      #   secret {
      #     secret = var.secret
      #     default_mode = var.default_mode
      #     items {
      #       path    = var.secret_item_path
      #       version = var.secret_item_version
      #       mode = var.secret_item_mode
      #     }
      #   }
      #   cloud_sql_instance {
      #     instances = var.instances
      #   }
      #   empty_dir {
      #     medium = var.medium
      #     size_limit = var.size_limit
      #   }
      #   gcs {
      #     bucket = var.bucket
      #     read_only = var.read_only
      #     mount_options = var.mount_options
      #   }
      #   nfs {
      #     server = var.server
      #     path = var.path
      #     read_only = var.read_only
      #   }
      # }
      timeout         = var.timeout
      service_account = var.service_account_email
      # execution_environment = var.execution_environment
      encryption_key = var.encryption_key
      # vpc_access {
      #   connector = var.connector
      #   egress = var.egress
      #   network_interfaces {
      #     network = var.network
      #     subnetwork = var.subnetwork
      #     tags = var.tags
      #   }
      # }
      max_retries = var.max_retries
    }
  }

  dynamic "binary_authorization" {
    for_each = var.binary_authorization != null ? [var.binary_authorization] : []

    content {
      # Use lookup to safely access optional attributes
      breakglass_justification = lookup(binary_authorization.value, "breakglass_justification", null)
      use_default              = lookup(binary_authorization.value, "use_default", null)
      policy                   = lookup(binary_authorization.value, "policy", null)
    }
  }

  deletion_protection = var.deletion_protection

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image,
      client,
      client_version,
    ]
  }
}

resource "google_cloud_run_v2_job_iam_member" "member" {
  for_each = { for item in var.iam : "${item.role}-${item.member}" => item }

  project  = google_cloud_run_v2_job.job.project
  location = google_cloud_run_v2_job.job.location
  name     = google_cloud_run_v2_job.job.name
  role     = each.value.role
  member   = each.value.member
}
