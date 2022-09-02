resource oci_identity_dynamic_group sharing {
    compartment_id = var.tenancy_ocid   # Dynamic group can only be created in the root compartment
    description    = "Needed for sharing function (cpauliat, April 2021)"
    matching_rule  = "ALL {resource.type = 'fnfunc', resource.id = '${var.sharing_function_id}'}"
    name           = "sharing_function"
}

resource oci_identity_policy sharing {
    depends_on     = [ oci_identity_dynamic_group.sharing ]
    compartment_id = var.compartment_id
    description    = "Needed for sharing function"
    name           = "sharing_function"
    statements     = [ "allow dynamic-group sharing_function to use all-resources in compartment id ${compartment_id}" ]
}