output "address" {
  description = "VPN gateway address."
  value       = local.gateway_address
}

output "gateway" {
  description = "VPN gateway resource."
  value       = google_compute_vpn_gateway.gateway
}

output "name" {
  description = "VPN gateway name."
  value       = google_compute_vpn_gateway.gateway.name
}

output "random_secret" {
  description = "Generated secret."
  value       = local.secret
}

output "self_link" {
  description = "VPN gateway self link."
  value       = google_compute_vpn_gateway.gateway.self_link
}

output "tunnel_names" {
  description = "VPN tunnel names."
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name].name
  }
}

output "tunnel_self_links" {
  description = "VPN tunnel self links."
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name].self_link
  }
}

output "tunnels" {
  description = "VPN tunnel resources."
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name]
  }
}
