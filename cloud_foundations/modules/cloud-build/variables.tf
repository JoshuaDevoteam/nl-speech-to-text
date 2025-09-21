variable "project" {
  type        = string
  description = "The project id on which to create the trigger"
  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project))
    error_message = "Must be letters, digits, hyphens. or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "trigger_name" {
  type        = string
  description = "The name of the trigger"
}

variable "regex" {
  type        = string
  description = "Regex to match the Tag or branch name."
}

variable "invert_regex" {
  type        = bool
  default     = false
  description = "Match on everything EXCEPT the Regex."
}

variable "repo_type" {
  type        = string
  default     = "GITHUB"
  description = "Git provider"
  validation {
    condition     = contains(["GITHUB"], var.repo_type)
    error_message = "Must be one of: GITHUB."
  }
}

variable "repo_name" {
  type        = string
  description = "Name of the github repository"
}

variable "repo_owner" {
  type        = string
  description = "Name of the github repository owner"
}

variable "substitutions" {
  type        = map(string)
  description = "Substitution variables for the build"
}

variable "config_path" {
  type        = string
  description = "Path to build config file"
}

variable "included_files" {
  type        = list(string)
  description = "List of paths to files that will trigger builds"
}

variable "ignored_files" {
  type        = list(string)
  description = "List of paths to files that will be ignored by the trigger"
}

variable "disabled" {
  type        = bool
  default     = false
  description = "Whether the trigger is disabled"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the trigger"
}

variable "on" {
  type        = string
  default     = "PUSH_BRANCH"
  description = "Action to fire the trigger"
  validation {
    condition     = contains(["PUSH_BRANCH", "PUSH_TAG", "PULL_REQUEST"], var.on)
    error_message = "Must be one of: PUSH_BRANCH, PUSH_TAG, PULL_REQUEST."
  }
}

variable "pull_request_comment_control" {
  type        = string
  default     = "COMMENTS_DISABLED"
  description = "One of `COMMENTS_DISABLED`, `COMMENTS_ENABLED` or `COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY` must be provided."
  validation {
    condition     = contains(["COMMENTS_DISABLED", "COMMENTS_ENABLED", "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"], var.pull_request_comment_control)
    error_message = "Must be either `COMMENTS_DISABLED`, `COMMENTS_ENABLED` or `COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY`."
  }
}

variable "service_account" {
  type        = string
  description = "The service account used for all user-controlled operations"
  validation {
    condition     = can(regex("^projects/.+/serviceAccounts/.+$", var.service_account))
    error_message = "Must have format 'projects/{PROJECT_ID}/serviceAccounts/{ACCOUNT_ID_OR_EMAIL}'"
  }
}