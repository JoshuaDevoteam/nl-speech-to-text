variable "groups" {
  type = map(object({
    email       = string
    description = optional(string)
  }))
  description = <<-EOT
    Map of groups to create with their user members.
      `email`: email address of the group
      `description`: description for the group
  EOT
  default     = {}
}

variable "folders" {
  type = map(object({
    folder_id     = string
    groups        = optional(map(list(string)), {})
    sa            = optional(map(list(string)), {})
    users         = optional(map(list(string)), {})
    principals    = optional(map(list(string)), {})
    principalSets = optional(map(list(string)), {})
    conditionals = optional(map(object({
      condition     = string
      description   = optional(string)
      groups        = optional(map(list(string)), {})
      sa            = optional(map(list(string)), {})
      users         = optional(map(list(string)), {})
      principals    = optional(map(list(string)), {})
      principalSets = optional(map(list(string)), {})
    })), {})
  }))
  description = <<-EOT
    Map of folders with their bindings
      `folder_id`: the id of the folder, created in the resource manager module
      `groups, sa, users, principals, principalSets`: maps of IAM entities that will have a role on the folder. For groups and service accounts the key is the alias used. The value is a list of roles that will be granted on the folder.
      `conditionals`: Maps with the configuration for assigning conditional IAM permissions. The key will be used as the name of the condition
        `condition`: Textual representation of an expression in Common Expression Language syntax
        `description`: An optional description of the condition
        `groups, sa, users, principals, principalSets`: Same as for the non-conditional IAM bindings
  EOT
  default     = {}
}

variable "projects" {
  type = map(object({
    project_id    = string
    groups        = optional(map(list(string)), {})
    sa            = optional(map(list(string)), {})
    users         = optional(map(list(string)), {})
    principals    = optional(map(list(string)), {})
    principalSets = optional(map(list(string)), {})
    conditionals = optional(map(object({
      condition     = string
      description   = optional(string)
      groups        = optional(map(list(string)), {})
      sa            = optional(map(list(string)), {})
      users         = optional(map(list(string)), {})
      principals    = optional(map(list(string)), {})
      principalSets = optional(map(list(string)), {})
    })), {})
  }))
  description = <<-EOT
    Map of projects with their bindings
      `project_id`: the id of the project, created in the resource manager module
      `groups, sa, users, principals, principalSets`: maps of IAM entities that will have a role on the project. For groups and service accounts the key is the alias used. The value is a list of roles that will be granted on the project.
      `conditionals`: Maps with the configuration for assigning conditional IAM permissions. The key will be used as the name of the condition
        `condition`: Textual representation of an expression in Common Expression Language syntax
        `description`: An optional description of the condition
        `groups, sa, users, principals, principalSets`: Same as for the non-conditional IAM bindings
  EOT
  default     = {}
}

variable "service_accounts" {
  type = map(object({
    gcp_project_id = optional(string)
    description    = optional(string)
    display_name   = optional(string)
    create         = optional(bool, true)
    disabled       = optional(bool)
    email          = optional(string)
    groups         = optional(map(list(string)), {})
    sa             = optional(map(list(string)), {})
    users          = optional(map(list(string)), {})
    principals     = optional(map(list(string)), {})
    principalSets  = optional(map(list(string)), {})
    conditionals = optional(map(object({
      condition     = string
      description   = optional(string)
      groups        = optional(map(list(string)), {})
      sa            = optional(map(list(string)), {})
      users         = optional(map(list(string)), {})
      principals    = optional(map(list(string)), {})
      principalSets = optional(map(list(string)), {})
    })), {})
    force_create_policy = optional(bool, false)
    tenant              = optional(string)
    environment         = optional(string)
    stage               = optional(string)
    name                = optional(string)
    attributes          = optional(list(string))
    label_order         = optional(list(string))
  }))
  description = <<-EOT
    Map of service accounts. The key of the map is the alias that will be used in the other modules.
    The object contains properties of the service accounts:
      `gcp_project_id`: the GCP project the service account will reside in
      `description`: a description of the service account
      `display_name`: a more human readable name for the service account. Default the generated account_id will be used.
      `create`: create a new service account with the information or this is the definition of an existing service account
      `disabled`: CURRENTLY NOT USED disable a service account after creation
      `email`: when service account don't need to be created, this email address will identify the service account
      `groups, sa, users, principals, principalSets`: maps of IAM entities that will have a role on the service account resource. For groups and service accounts the key is the alias used. The value is a list of roles that will be granted on the service account.
      `conditionals`: Maps with the configuration for assigning conditional IAM permissions. The key will be used as the name of the condition
        `condition`: Textual representation of an expression in Common Expression Language syntax
        `description`: An optional description of the condition
        `groups, sa, users, principals, principalSets`: Same as for the non-conditional IAM bindings
      `force_create_policy`: (Optional) If set to true, an IAM policy for this service account will be created regardless of whether any bindings are present
      `tenant, environment, stage, name, attributes, label_order`: inputs for automatic ID generation
  EOT
  default     = {}
}

variable "tfstates" {
  type = map(object({
    project          = string
    service_accounts = list(string)
    location         = string
    tenant           = optional(string)
    environment      = optional(string)
    stage            = optional(string)
    name             = optional(string)
    attributes       = optional(list(string))
    label_order      = optional(list(string))
  }))
  description = <<EOF
    The tfstates buckets that will be created.
    department: The departments name e.g. ml, anthos
    project: The GCP project id where the bucket will be created.
    service_account: The alias of the service account that is created and defined in the service_accounts block.
    location: Location of the bucket. E.g. EU, US or europe-west1
  EOF
  default     = {}
}
