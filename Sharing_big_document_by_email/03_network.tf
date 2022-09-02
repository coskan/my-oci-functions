# ------ Create a new VCN
resource oci_core_vcn sharing {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_id
  display_name   = "sharing-vcn"
  dns_label      = "sharing"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway sharing {
  compartment_id = var.compartment_id
  display_name   = "sharing-internet-gateway"
  vcn_id         = oci_core_vcn.sharing.id
}

# ------ Create a new Route Table to be used in public subnet
resource oci_core_route_table sharing {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.sharing.id
  display_name   = "sharing-public1-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.sharing.id
  }
}

# ------ Create new security list to be used in the new subnet
resource oci_core_security_list sharing {
  compartment_id = var.compartment_id
  display_name   = "sharing-public-security-list"
  vcn_id         = oci_core_vcn.sharing.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
}

# ------ Create a public subnet in the new VCN
resource oci_core_subnet sharing-public {
  cidr_block          = var.cidr_subnet_public
  display_name        = "sharing-public"
  dns_label           = "public"
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.sharing.id
  route_table_id      = oci_core_route_table.sharing.id
  security_list_ids   = [oci_core_security_list.sharing.id]
  dhcp_options_id     = oci_core_vcn.sharing.default_dhcp_options_id
}


