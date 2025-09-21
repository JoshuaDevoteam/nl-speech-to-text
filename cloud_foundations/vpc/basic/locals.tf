locals {
  vpcs_with_default_route = {
    for name, vpc in var.vpc : name => vpc
    if try(vpc.has_default_route, true)
  }
}
