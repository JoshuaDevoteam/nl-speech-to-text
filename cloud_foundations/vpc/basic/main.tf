module "vpc" {
  for_each = var.vpc
  source   = "../../modules/network/vpc"

  project                        = each.value.project
  description                    = each.value.description
  subnets                        = each.value.subnets
  routing_mode                   = each.value.routing_mode
  skip_default_deny_fw           = lookup(each.value, "skip_default_deny_fw", false)
  delete_default_route_on_create = true # Will be created by Terraform so it's managed and can be removed at a later time
  firewall_logging_mode          = lookup(each.value, "firewall_logging_mode", null)


  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = lookup(each.value, "tenant", null)
  environment = lookup(each.value, "environment", null)
  stage       = lookup(each.value, "stage", null)
  name        = lookup(each.value, "name", null)
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
  context     = module.this.context

}

module "firewalls" {
  for_each            = var.firewalls
  source              = "../../modules/network/firewall"
  project             = each.value.project
  network             = each.value.network
  egress_allow_range  = lookup(each.value, "egress_allow_range", {})
  ingress_allow_tag   = lookup(each.value, "ingress_allow_tag", {})
  ingress_allow_range = lookup(each.value, "ingress_allow_range", {})
  egress_deny_range   = lookup(each.value, "egress_deny_range", {})
  depends_on          = [module.vpc]

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = lookup(each.value, "tenant", null)
  environment = lookup(each.value, "environment", null)
  stage       = lookup(each.value, "stage", null)
  name        = lookup(each.value, "name", null)
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
  context     = module.this.context
}

module "default_routes" {
  for_each = local.vpcs_with_default_route
  source   = "../../modules/network/routes"

  project          = each.value.project
  network          = module.vpc[each.key].network_link
  description      = "Terraform managed default route to the internet."
  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = lookup(each.value, "tenant", null)
  environment = lookup(each.value, "environment", null)
  stage       = lookup(each.value, "stage", null)
  name        = "${lookup(each.value, "name", "")}-default"
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
  context     = module.this.context
}

module "nat" {
  for_each = var.nats
  source   = "../../modules/network/nat"

  region               = each.value.region
  project              = each.value.project
  network              = each.value.network
  subnets              = lookup(each.value, "subnets", [])
  number_of_static_ips = lookup(each.value, "number_of_static_ips", 0)

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = lookup(each.value, "tenant", null)
  environment = lookup(each.value, "environment", null)
  stage       = lookup(each.value, "stage", null)
  name        = lookup(each.value, "name", null)
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
  context     = module.this.context

  depends_on = [
    module.vpc
  ]
}
