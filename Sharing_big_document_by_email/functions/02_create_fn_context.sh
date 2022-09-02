fn create context oci-oscemea001fra --provider oracle
fn use context oci-oscemea001fra

CPT=ocid1.compartment.oc1..aaaaaaaaxxxxxxxxxxxxxxxxxxx   
fn update context oracle.compartment-id $CPT
fn update context api-url https://functions.eu-frankfurt-1.oraclecloud.com
fn update context registry fra.ocir.io/oscemea001/myrepo-fra
fn update context oracle.profile OSCEMEA001fra

docker login fra.ocir.io -u oscemea001/christophe.pauliat@oracle.com