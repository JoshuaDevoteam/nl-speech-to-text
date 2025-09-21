
module "labels" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  namespace = "sa"
  context   = module.this.context
}

resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = module.labels.id
  display_name = var.display_name
  description  = var.description != "" ? var.description : var.display_name != "" ? var.display_name : module.labels.id
}
