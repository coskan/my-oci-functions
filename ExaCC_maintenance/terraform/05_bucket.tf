data oci_objectstorage_namespace exacc_maintenance {
    compartment_id = var.tenancy_ocid
}

resource oci_objectstorage_bucket exacc_maintenance {
    compartment_id = var.bucket_compartment_ocid
    name           = "ExaCC_dashboards"
    namespace      = data.oci_objectstorage_namespace.exacc_maintenance.namespace
}

