variable "cloud_groups" {
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

variable "cloud_folders" {
  type = map(object({
    folder_id = string
    groups    = map(list(string))
    sa        = map(list(string))
    users     = optional(map(list(string)))
  }))
  description = <<-EOT
    Map of folders with their bindings
      `folder_id`: the id of the folder, created in the resource manager module
      `groups`: a map of group aliases and the roles
      `sa`: a map of service account aliases and the roles
      `users`: a map of user email addresses and the roles
  EOT
  default     = {}
}

variable "cloud_projects" {
  type = map(object({
    project_id = string
    groups     = optional(map(list(string)))
    sa         = optional(map(list(string)))
    users      = optional(map(list(string)))
  }))
  default = {}
}

variable "cloud_service_accounts" {
  type = map(object({
    gcp_project_id = optional(string)
    description    = optional(string)
    display_name   = optional(string)
    create         = optional(bool)
    disabled       = optional(bool)
    email          = optional(string)
    groups         = optional(map(list(string)))
    sa             = optional(map(list(string)))
    users          = optional(map(list(string)))
    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    name           = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
  }))
  description = <<-EOT
    Map of service accounts. The key of the map is the alis that will be used in the other modules.
    The object contains properties of the service accounts:
      `gcp_project_id`: the GCP project the service account will reside in
      `account_id`: the service account id. This will be used in the email address before the @ of the sa. e.g. sa-anthos-eng-be-iam, the email address will become sa-anthos-eng-be-iam@pj-dep-anthos-be-tf.iam.gserviceaccount.com
      `name`: a more human readable name for the service account. Default the account_id will be used.
      `description`: a description of the service account
      `create`: create a new service account with the information or this is the definition of an existing service account
      `email`: when service account don't need to be created, this email address will identify the service account
      `groups`: a map of groups that will have a role on the service account resource. The key is the alias of the group. The value is a list of roles that the group will get on the service account.
      `sa`: a map of service accounts that will have a role on the service account resource. The key is the alias of the service account, that will get roles on the service account.
      `users`: a map of user email addresses and the roles
  EOT
}

variable "cloud_tfstates" {
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

variable "data_folders" {
  default = {}
}

variable "ai_folders" {
  default = {}
}

variable "data_service_accounts" {
  default = {}
}

variable "ai_service_accounts" {
  default = {}
}

variable "data_projects" {
  default = {}
}

variable "ai_projects" {
  default = {}
}

variable "data_groups" {
  default = {}
}

variable "ai_groups" {
  default = {}
}

variable "data_tfstates" {
  default = {}
}

variable "ai_tfstates" {
  default = {}
}
