output "network_links" {
  value = tomap({
    for k, vpc in module.vpc : k => vpc.network_link
  })
}
