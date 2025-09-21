variable "gcp_organisation" {
  type        = string
  description = "The root organisation ID"
}
variable "resources_root_folder_id" {
  type        = string
  description = "The root folder under which to create new folders. Must exist. Leave empty to create resources under the Org node"
  default     = null
}
variable "billing_account" {
  type        = string
  description = "The billing account the projects will be linked to"
}
variable "resources_root" {
  description = "The root folders directly under the organisation node, with the projects per folder"
  type = map(object({
    folder_name = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}
variable "resources_l1" {
  description = "The folders directly under the root folders, with the projects per folder"
  type = map(object({
    parent_folder = string
    folder_name   = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}
variable "resources_l2" {
  description = "The folders directly under the l1 folders, with the projects per folder"
  type = map(object({
    parent_folder = string
    folder_name   = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}
variable "resources_l3" {
  description = "The folders directly under the l2 folders, with the projects per folder"
  type = map(object({
    parent_folder = string
    folder_name   = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}
variable "resources_l4" {
  description = "The folders directly under the l3 folders, with the projects per folder"
  type = map(object({
    parent_folder = string
    folder_name   = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}
variable "resources_l5" {
  description = "The folders directly under the l4 folders, with the projects per folder"
  type = map(object({
    parent_folder = string
    folder_name   = string
    projects = optional(map(object({
      project_id  = optional(string)
      apis        = optional(set(string), [])
      name        = optional(string)
      namespace   = optional(string, "pj")
      tenant      = optional(string)
      environment = optional(string)
      stage       = optional(string)
      labels      = optional(map(string), {})
    })), {})

    tenant         = optional(string)
    environment    = optional(string)
    stage          = optional(string)
    attributes     = optional(list(string))
    label_order    = optional(list(string))
    labels_as_tags = optional(list(string))
    labels         = optional(map(string), {})
  }))
  default = {}
}


variable "apis" {
  type        = map(set(string))
  description = "Map of project_id as KEY and a set of apis to enable as VALUE"
  default     = {}
}

variable "disable_api_on_destroy" {
  type        = bool
  default     = false
  description = "If set to true, APIs that are removed from Terraform are disabled."
}
