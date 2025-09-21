output "id" {
  value = google_dns_managed_zone.dns_zone.id
}

output "name_servers" {
  value = google_dns_managed_zone.dns_zone.name_servers
}
