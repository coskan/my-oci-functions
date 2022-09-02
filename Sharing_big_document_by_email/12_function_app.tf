resource oci_functions_application sharing {
    compartment_id = var.compartment_id
    display_name   = "sharing_app"
    subnet_ids     = [ oci_core_subnet.sharing-public.id ]
}