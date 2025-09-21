variable "resources_root_folder_id" {
  type        = string
  description = "The root folder under which to create new folders. Must exist. Leave empty to create resources under the Org node"
  default     = null
}

variable "billing_account" {
  type        = string
  description = "The billing account the projects will be linked to"
}

variable "cloud_resources_root" {
  description = "The root folders directly under the organisation node, with the projects per folder"
  default     = {}
  type        = any
}
variable "cloud_resources_l1" {
  description = "The folders directly under the root folders, with the projects per folder"
  default     = {}
  type        = any
}
variable "cloud_resources_l2" {
  description = "The folders directly under the root folders, with the projects per folder"
  default     = {}
  type        = any
}

//TODO RIK-JONAS how to treat API's, in project or separate?

variable "data_resources_root" {
  default = {}
}

variable "ai_resources_root" {
  default = {}
}
