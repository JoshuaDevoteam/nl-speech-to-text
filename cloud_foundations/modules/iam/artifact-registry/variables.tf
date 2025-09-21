variable "repo_project_id" {
  type        = string
  description = "Project id the Artifact Registry repo belongs to."
}

variable "repo_location" {
  type        = string
  description = "The location the Artifact Registry repo resides in."
}

variable "repo_name" {
  type        = string
  description = "Name of the Artifact Registry repo."
}

variable "bindings" {
  type        = map(list(string))
  description = "Map of bindings, with the keys being the roles and the values lists withe the members for those roles."
  default     = {}
}

variable "conditional_bindings" {
  description = "A map of objects, with the key as the title for the conditional binding, and as value the role, members, condition, and optionally a description."
  type = map(object({
    title       = string
    role        = string
    members     = set(string)
    condition   = string
    description = optional(string)
  }))
  default = {}
}
