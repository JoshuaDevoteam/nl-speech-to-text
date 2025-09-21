module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  context = module.this.context
}
module "labels_router" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace = "crt-nat"
  context   = module.labels.context
}
module "labels_nat" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace = "nat"
  context   = module.labels.context
}

module "labels_ip" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace = "spi-nat"
  context   = module.labels.context
}

resource "google_compute_router" "router" {
  name    = module.labels_router.id
  region  = var.region
  network = var.network
  project = var.project
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project
  name                               = module.labels_nat.id
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.number_of_static_ips == 0 ? "AUTO_ONLY" : "MANUAL_ONLY"
  nat_ips                            = [for address in google_compute_address.nat_address : address.self_link]
  source_subnetwork_ip_ranges_to_nat = length(var.subnets) == 0 ? "ALL_SUBNETWORKS_ALL_IP_RANGES" : "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = var.subnets
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_address" "nat_address" {
  count = var.number_of_static_ips

  name         = "${module.labels_ip.id}-${count.index}"
  project      = var.project
  description  = "Reserved static public IP for NAT ${module.labels_nat.id}"
  address_type = "EXTERNAL"
  region       = var.region
}
