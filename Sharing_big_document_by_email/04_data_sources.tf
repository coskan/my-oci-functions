# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# --------- Get object storage namespace (needed for OS buckets)
data oci_objectstorage_namespace namespace {
  compartment_id = var.compartment_id
}
