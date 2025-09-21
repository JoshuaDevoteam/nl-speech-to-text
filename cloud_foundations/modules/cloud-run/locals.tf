# used in run.tf, but is needed?

locals {
  env_vars = merge({
    for k, v in var.environment_variables : k => {
      value = v
    }
    }, {
    for k, v in var.secrets : k => {
      secret_key_ref = {
        key  = v.version
        name = v.name
      }
    }
  })

  annotations = {
    "autoscaling.knative.dev/minScale"     = var.min_instance_count
    "autoscaling.knative.dev/maxScale"     = var.max_instance_count
    "run.googleapis.com/startup-cpu-boost" = var.startup_cpu_boost
  }

  vpc = {
    "run.googleapis.com/vpc-access-connector" = var.vpc_access_connector_id
    "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
  }

  all_annotations = var.vpc_access_connector_id != null ? merge(local.annotations, local.vpc) : local.annotations
}