output "attachment" {
  value = { for name, attachment in google_compute_interconnect_attachment.attachment : name => {
    cloud_router_ip_address    = attachment.cloud_router_ip_address
    customer_router_ip_address = attachment.customer_router_ip_address
    pairing_key                = attachment.pairing_key
    partner_asn                = attachment.partner_asn
    private_interconnect_info  = attachment.private_interconnect_info
  } }
}
