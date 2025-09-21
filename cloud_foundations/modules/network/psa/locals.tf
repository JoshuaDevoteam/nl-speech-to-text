locals {
  addresses_to_reserve = { for value in flatten([
    for key, psa in var.private_service_access :
    [
      for name, range in psa.cidr_ranges :
      {
        psa_key    = key
        range      = range
        attributes = [psa.name, name]
        name       = name
      }
    ]
    ]) : "${value.psa_key}-${value.name}" => value
  }
}
