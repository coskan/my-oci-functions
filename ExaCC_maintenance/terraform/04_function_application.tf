resource oci_functions_application exacc_maintenance {
    compartment_id = var.function_compartment_ocid
    display_name   = "ExaCC_app"
    subnet_ids     = [ oci_core_subnet.exacc_maintenance.id ]
}