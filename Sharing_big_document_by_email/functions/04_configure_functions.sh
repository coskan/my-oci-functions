#!/bin/bash

FUNC_ID="ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaaxxxxxxxxxxxxxxxxxxx"
PROFILE=OSCEMEA001fra
CONFIG='{
  "par_validity_in_days": "5",
  "email_sender": "noreply@oci-sharing-function.com",
  "email_sender_name": "OCI Sharing Function",
  "email_recipient": "christophe.pauliat@oracle.com",
  "email_smtp_user": "ocid1.user.oc1..aaaaaaaamoxxxxxxxxx@ocid1.tenancy.oc1..aaaaaaaaxxxxxxxxxxxxxxxx",
  "email_smtp_host": "smtp.email.eu-frankfurt-1.oci.oraclecloud.com",
  "email_smtp_port": "587",
  "email_smtp_pwd_secret_id": "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaanmxxxxxxxxxxxxxxxx"
}'

oci --profile $PROFILE fn function update --function-id $FUNC_ID --config "$CONFIG"
