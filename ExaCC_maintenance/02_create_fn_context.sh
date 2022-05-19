fn create context <name-context> --provider oracle
fn use context <name-context>

CPT=ocid1.compartment.oc1..aaaaaaaa72rvuwmv2k5ega6xxxxxxx   
fn update context oracle.compartment-id $CPT
fn update context api-url https://functions.eu-frankfurt-1.oraclecloud.com
fn update context registry fra.ocir.io/<tenancy-namespace>/<repo-name>
fn update context oracle.profile <oci-profile>

docker login fra.ocir.io -u <tenancy-namespace>/<oci-username>
# passwd is Auth Token for OCI local user <oci-username>