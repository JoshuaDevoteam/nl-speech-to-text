variable "project" {
  type        = string
  description = "The name of the project where the Service Account should be deployed"
}

variable "action" {
  type        = string
  description = "The action to perform in the default service account. Valid values are: DEPRIVILEGE, DELETE, DISABLE. Note that DEPRIVILEGE action will ignore the REVERT configuration in the restore_policy"
}

variable "restore_policy" {
  type        = string
  description = "The action to be performed in the default service accounts on the resource destroy. Valid values are NONE, REVERT and REVERT_AND_IGNORE_FAILURE. It is applied for any action but in the DEPRIVILEGE. If set to REVERT it attempts to restore all default SAs but the DEPRIVILEGE action. If set to REVERT_AND_IGNORE_FAILURE it is the same behavior as REVERT but ignores errors returned by the API."
}
