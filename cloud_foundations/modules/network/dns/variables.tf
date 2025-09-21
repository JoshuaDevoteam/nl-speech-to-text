variable "project" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "dns_name" {
  type        = string
  description = "The DNS name of this managed zone, for instance \"example.com.\"."
}

variable "description" {
  type        = string
  description = "A textual description field. Defaults to 'Managed by Terraform'."
  default     = ""
}

variable "visibility" {
  type        = string
  description = "The zone's visibility: public zones are exposed to the Internet, while private zones are visible only to Virtual Private Cloud resources. Default value is private. Possible values are private and public."
  default     = "private"
}

variable "reverse_lookup" {
  type        = bool
  description = "Specifies if this is a managed reverse lookup zone. If true, Cloud DNS will resolve reverse lookup queries using automatically configured records for VPC resources. This only applies to networks listed under private_visibility_config."
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "Set this true to delete all records in the zone."
  default     = false
}

variable "dnssec_config" {
  type = object({
    kind          = optional(string)
    non_existence = optional(string)
    state         = optional(string)
    default_key_specs = optional(object({
      algorithm  = optional(string)
      key_length = optional(string)
      key_type   = optional(string)
      kind       = optional(string)
    }))
  })
  description = <<-EOT
    DNSSEC configuration. If visibility is private, dnssec cannot be set. If visibility is public dnssec must be set.
      kind: Identifies what kind of resource this is
      non_existence: Specifies the mechanism used to provide authenticated denial-of-existence responses. non_existence can only be updated when the state is off. Possible values are nsec and nsec3.
      state: Specifies whether DNSSEC is enabled, and what mode it is in Possible values are off, on, and transfer.
      default_key_specs: Specifies parameters that will be used for generating initial DnsKeys for this ManagedZone. If you provide a spec for keySigning or zoneSigning, you must also provide one for the other. default_key_specs can only be updated when the state is off.
        algorithm: String mnemonic specifying the DNSSEC algorithm of this key Possible values are ecdsap256sha256, ecdsap384sha384, rsasha1, rsasha256, and rsasha512.
        key_length: Length of the keys in bits
        key_type: Specifies whether this is a key signing key (KSK) or a zone signing key (ZSK). Key signing keys have the Secure Entry Point flag set and, when active, will only be used to sign resource record sets of type DNSKEY. Zone signing keys do not have the Secure Entry Point flag set and will be used to sign all other types of resource record sets. Possible values are keySigning and zoneSigning.
        kind: Identifies what kind of resource this is
  EOT
  default     = null
}

variable "private_visibility_config" {
  type = object({
    networks = list(object({
      network_url = string
    }))
  })
  description = <<-EOT
    For privately visible zones, the set of Virtual Private Cloud resources that the zone is visible from.
      networks: The list of VPC networks that can see this zone.
        network_url: The id or fully qualified URL of the VPC network to bind to. This should be formatted like projects/{project}/global/networks/{network} or https://www.googleapis.com/compute/v1/projects/{project}/global/networks/{network}
  EOT
  default     = null
}

variable "forwarding_config" {
  type = object({
    target_name_servers = list(object({
      ipv4_address : string
      forwarding_path : optional(string)
    }))
  })
  description = <<-EOT
    The presence for this field indicates that outbound forwarding is enabled for this zone. The value of this field contains the set of destinations to forward to.
      target_name_servers: List of target name servers to forward to. Cloud DNS will select the best available name server if more than one target is given.
        ipv4_address:  IPv4 address of a target name server.
        forwarding_path: Forwarding path for this TargetNameServer. If unset or default Cloud DNS will make forwarding decision based on address ranges, i.e. RFC1918 addresses go to the VPC, Non-RFC1918 addresses go to the Internet. When set to private, Cloud DNS will always send queries through VPC for this target Possible values are default and private.
  EOT
  default     = null
}

variable "peering_config" {
  type = object({
    target_network = object({
      network_url = string
    })
  })
  description = <<-EOT
    The presence of this field indicates that DNS Peering is enabled for this zone. The value of this field contains the network to peer with.
      target_network: The network with which to peer.
        network_url: The id or fully qualified URL of the VPC network to forward queries to. This should be formatted like projects/{project}/global/networks/{network} or https://www.googleapis.com/compute/v1/projects/{project}/global/networks/{network}
  EOT
  default     = null
}

variable "service_directory_config" {
  type = object({
    namespace = object({
      namespace_url = string
    })
  })
  description = <<-EOT
    The presence of this field indicates that this zone is backed by Service Directory. The value of this field contains information related to the namespace associated with the zone.
      namespace: The namespace associated with the zone.
        namespace_url: The fully qualified or partial URL of the service directory namespace that should be associated with the zone. This should be formatted like https://servicedirectory.googleapis.com/v1/projects/{project}/locations/{location}/namespaces/{namespace_id} or simply projects/{project}/locations/{location}/namespaces/{namespace_id} Ignored for public visibility zones.
  EOT
  default     = null
}

variable "records" {
  type = map(object({
    type    = string
    ttl     = optional(number)
    rrdatas = optional(list(string))
  }))
  description = <<-EOT
    A map of records with as key the name of the record
      record: A single DNS record that exists on a domain name (i.e. in a managed zone). This record defines the information about the domain and where the domain / subdomains direct to.
        type: One of valid DNS resource types. Possible values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV, TLSA, and TXT.
        ttl: Number of seconds that this ResourceRecordSet can be cached by resolvers.
        rrdatas: The string data for the records in this record set whose meaning depends on the DNS type. For TXT record, if the string data contains spaces, add surrounding \" if you don't want your string to get split on spaces. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string (e.g. "first255characters\"\"morecharacters").
  EOT
}
