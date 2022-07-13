#!/bin/bash

FUNC_ID="ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaa4dhpcakxxxxxxx"
PROFILE=<oci-profile>
CONFIG='{
  "bucket_name": "ExaCC_maintenance_reports",
  "bucket_region": "eu-frankfurt-1",
  "par_for_bucket_read": "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/xxxxxxxxxxxxxxxxxxxxx/n/tenant/b/ExaCC_maintenance_reports/o/",
  "email_sender": "noreply@oci-exacc-reports.com",
  "email_sender_name": "OCI ExaCC patching reports)",
  "email_recipients": "christophe.pauliat@oracle.com,anotheremail@example.com",
  "email_smtp_user": "ocid1.user.oc1..aaaaaaaamotj4cs75axxxxxxxxxxxxxxxxxxx@ocid1.tenancy.oc1..aaaaaaaafipe4lmow7rfrn5f3egpgxxxxxxxxx.kk.com",
  "email_smtp_host": "smtp.email.us-ashburn-1.oci.oraclecloud.com",
  "email_smtp_port": "587",
  "email_smtp_pwd_secret_id": "ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaanmvrbexxxxxxxxxxxxxxxxxx",
  "vault_secret_region": "eu-frankfurt-1",
  "exainfra_group1_name": "preprod",
  "exainfra_group1_ids": "ocid1.exadatainfrastructure.oc1.eu-frankfurt-1.abtheljr5wzqsqc7xxxxxxxxxx",
  "exainfra_group2_name": "prod",
  "exainfra_group2_ids": "ocid1.exadatainfrastructure.oc1.eu-frankfurt-1.abtheljtrl4efvxxxxxxxxxxxx,ocid1.exadatainfrastructure.oc1.eu-frankfurt-1.abtheljtrl4efvxxxxyyyyyyyyyyyyyy",
  "exainfra_group3_name": "test",
  "exainfra_group3_ids": "ocid1.exadatainfrastructure.oc1.eu-frankfurt-1.abtheljtknxxxxxxxxxxxxxxxx"
}'

oci --profile $PROFILE fn function update --function-id $FUNC_ID --config "$CONFIG"
