resource oci_email_sender sharing {
  provider       = oci.ashburn
  compartment_id = var.reg_compartment_id
  email_address  = "noreply@oci-sharing-function.com"
}

