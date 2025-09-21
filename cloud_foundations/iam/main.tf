provider "google" {
  # This is required to run the terraform code as the service account
  impersonate_service_account = "sa-root-tf-iam@pj-terra-speech-text-main.iam.gserviceaccount.com"
  user_project_override       = true
  billing_project             = "pj-terra-speech-text-main"
  batching {
    send_after      = "1s"
    enable_batching = true
  }
}

terraform {
  backend "gcs" {
    bucket                      = "gcs-tf-state-iam-pj-terra-speech-text-main"
    prefix                      = "terraform/state/iam"
    impersonate_service_account = "sa-root-tf-iam@pj-terra-speech-text-main.iam.gserviceaccount.com"
  }
}

module "basic" {
  source           = "./basic"
  groups           = merge(var.cloud_groups, var.ai_groups, var.data_groups)
  projects         = merge(var.cloud_projects, var.ai_projects, var.data_projects)
  service_accounts = merge(var.cloud_service_accounts, var.ai_service_accounts, var.data_service_accounts)
  folders          = merge(var.cloud_folders, var.ai_folders, var.data_folders)
  tfstates         = merge(var.cloud_tfstates, var.ai_tfstates, var.data_tfstates)
}

locals {

}
