# ---------- (Documentação NETWORK) ---------- #

#  ----  VCN  ----  #

resource "oci_core_vcn" "vcn_principal" {
  compartment_id = var.compartment
  cidr_block     = var.ipv4_vcn
  display_name   = "VCN-${var.name}"
  dns_label      = "vcn"
}

#  ----  Subnet Publica  ----  #

resource "oci_core_subnet" "sub_pub" {
  compartment_id      = var.compartment
  vcn_id              = oci_core_vcn.vcn_principal.id
  cidr_block          = var.ipv4_sub_pub
  display_name        = "Public Subnet-${var.name}"
  availability_domain = var.domain
  dns_label           = "subpublic"
  route_table_id      = oci_core_route_table.route_tab.id
  security_list_ids   = [oci_core_security_list.list_sec_pub.id]
}

#  ----   Subnet Privada  ----  #

resource "oci_core_subnet" "sub_pri" {
  compartment_id      = var.compartment
  vcn_id              = oci_core_vcn.vcn_principal.id
  cidr_block          = var.ipv4_sub_pri
  display_name        = "Private Subnet-${var.name}"
  availability_domain = var.domain
  dns_label           = "subprivate"
  route_table_id      = oci_core_route_table.route_sec.id
  security_list_ids   = [oci_core_security_list.list_sec_pri.id]
}

#  ----  Internet Gateway  ----  #

resource "oci_core_internet_gateway" "internet_gate" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id
  display_name   = "Internet Gateway"
}

#  ----  Gateway NAT  ----  #

resource "oci_core_nat_gateway" "nat_gate" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id
  display_name   = "NAT Gateway"
}

#  ----  Tabela de Roteamento  ----  #

resource "oci_core_route_table" "route_tab" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id
  display_name   = "Tabela_roteamento"

  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gate.id
    destination       = "0.0.0.0/0"
  }
}

#  ----  Tabela de Roteamento Private  ----  #

resource "oci_core_route_table" "route_sec" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id
  display_name   = "Tabela_roteamento_private"

  route_rules {
    network_entity_id = oci_core_nat_gateway.nat_gate.id
    destination       = "0.0.0.0/0"
  }
}

# ---------- (Documentação SECURITY) ---------- #

#  ----  Lista de segurança subnet Publica  ----  #

resource "oci_core_security_list" "list_sec_pub" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = "22"
      max = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = "8080"
      max = "8080"
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }
}

#  ----  Lista de segurança subnet Privada  ----  #

resource "oci_core_security_list" "list_sec_pri" {
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.vcn_principal.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.ipv4_sub_pub
    tcp_options {
      min = "22"
      max = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.ipv4_sub_pub
    tcp_options {
      min = "8080"
      max = "8080"
    }
  }
  
  ingress_security_rules {

    protocol = "1"
    source   = var.ipv4_sub_pub
  }
}