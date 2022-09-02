resource oci_events_rule sharing {
    actions {
        actions {
            action_type = "FAAS"
            is_enabled  = "true"
            description = "Execute a Function when a new object is uploaded to bucket '${var.sharing_bucket_name}'"
            function_id = var.sharing_function_id
        }
    }
    compartment_id = var.reg_compartment_id
    condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"additionalDetails\":{\"bucketName\":[\"sharing\"]}}}"
    display_name   = "exec_sharing_function"
    description    = "Execute a Function when a new object is uploaded to bucket '${var.sharing_bucket_name}'"
    is_enabled     = "true"
}