variable "account_id" {
  type        = string
  description = "The account id for the Key Service Account"
}

variable "project" {
  type        = string
  description = "The name of the project where the service account policy should be applied to"
}

variable "display_name" {
  type        = string
  description = "The Display name for the Key Servie Account. You can leave it empty since it's an optional parameter"
}

variable "service_account_id" {
  type        = string
  description = "The Service account id of the Key. This can be a string in the format {ACCOUNT} or projects/{PROJECT_ID}/serviceAccounts/{ACCOUNT}, where {ACCOUNT} is the email address or unique id of the service account. If the {ACCOUNT} syntax is used, the project will be inferred from the account. Ex: google_service_account.key_sa.name"
}

variable "public_key_type" {
  type        = string
  description = "The output format of the public key requested. TYPE_X509_PEM_FILE is the default output format."
}

variable "private_key_type" {
  type        = string
  description = "The output format of the private key. TYPE_GOOGLE_CREDENTIALS_FILE is the default output format."
}

variable "rotation_days" {
  type        = number
  description = "The number of the days for when the key rotation should occur. Default: 30 days"
}

variable "description" {
  type        = string
  description = "The description for the Service Account"
}

variable "disabled" {
  type        = bool
  description = "Whether a service account is disabled or not. Defaults to false. This field has no effect during creation. Must be set after creation to disable a service account."
}
