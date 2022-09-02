resource oci_objectstorage_bucket sharing {
  compartment_id = var.compartment_id
  name           = var.sharing_bucket_name
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  access_type    = "NoPublicAccess"
  object_events_enabled = true
}

# ---- Create a lifecycle policy to delete objects after 5 days
resource oci_objectstorage_object_lifecycle_policy sharing {
  bucket         = oci_objectstorage_bucket.sharing.name
  namespace      = data.oci_objectstorage_namespace.namespace.namespace

  rules {
    action      = "DELETE"
    is_enabled  = true
    name        = "delete-older-than-5days"
    time_amount = "5"
    time_unit   = "DAYS"
    target      = "objects"
  }
}