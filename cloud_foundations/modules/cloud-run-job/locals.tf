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
}
