### Sharing_big_document_by_email

This function can be used to easily share big documents by email (storing the document in OCI object storage and creating a link to easily download it from there):

- The user uploads the document to an OCI bucket (new object), for exemple using OCI CLI in a script
- OCI detects the upload of the file to the bucket and use an Event rule to trigger the execution of the OCI Function
- The OCI function creates a Pre-authenticated request (PAR) allowing READ for this object for a few days
- The OCI function sends the PAR (HTML link) by email
- The user receives the email and can send the PAR to someone else so that he/she can easily download the document (before the PAR expires)

