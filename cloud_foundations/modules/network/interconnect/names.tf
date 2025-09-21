module "router_name" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0 # requires Terraform >= 0.13.0

  namespace = "crt"
  context   = module.this.context
}

module "attachment_name" {
  for_each = var.attachments
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "vat"
  context    = local.no_attribute_context
  attributes = coalesce(each.value.attributes, [each.key])
}

# These modules are probably not needed as these names will be auto generated and the resources will have to be imported.
# In this case, override_names will be set to true
module "interface_name" {
  for_each = { for key, attachment in var.attachments : key => attachment if attachment.activated && !attachment.override_names }
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "crti"
  context    = local.no_attribute_context
  attributes = coalesce(each.value.attributes, [each.key])
}

module "peer_name" {
  for_each = { for key, attachment in var.attachments : key => attachment if attachment.activated && !attachment.override_names }
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace  = "crtp"
  context    = local.no_attribute_context
  attributes = coalesce(each.value.attributes, [each.key])
}

locals {
  no_attribute_context = merge(module.this.context, { attributes = null })
}
