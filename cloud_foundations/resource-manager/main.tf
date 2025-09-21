provider "google" {
  impersonate_service_account = "sa-root-tf-rm@pj-terra-speech-text-main.iam.gserviceaccount.com"
  user_project_override       = true
  billing_project             = "pj-terra-speech-text-main"
  batching {
    send_after      = "1s"
    enable_batching = true
  }
}

terraform {
  backend "gcs" {
    bucket                      = "gcs-tf-state-rm-pj-terra-speech-text-main"
    prefix                      = "terraform/state/rm"
    impersonate_service_account = "sa-root-tf-rm@pj-terra-speech-text-main.iam.gserviceaccount.com"
  }
}

module "basic" {
  source                   = "./basic"
  gcp_organisation         = ""
  resources_root_folder_id = var.resources_root_folder_id
  billing_account          = var.billing_account
  resources_root           = merge(var.cloud_resources_root, var.data_resources_root, var.ai_resources_root)
  resources_l1             = var.cloud_resources_l1
  label_value_case         = "none"
  label_order              = ["name"]
  regex_replace_chars      = "/[^a-zA-Z0-9-]\\s/"
}
