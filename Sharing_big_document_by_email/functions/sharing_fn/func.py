# ----------------------------------------------------------------------------------------------------
# This OCI function is called by an OCI Event when a new object is created in an Object Storage Bucket
#
# This function:
# 1) gets the name of the object just created
# 2) creates a PAR (pre-auth request) for the object allowing read for a given duration
# 3) send an email containing the PAR to a given email address an SMTP Email Server
#    note: the SMTP Email Server can be from OCI Email Delivery service or NOT
#
# Prerequisites:
# - Dynamic Group and Policy to allow Resource Principal Authentication
# - Configure following variables (keys/values) in the Function configuration:
#   par_validity_in_days     : number of days before PAR expiry
#   email_sender             : email address of the sender     
#   email_sender_name        : email name of the sender  
#   email_recipient          : email address of the recipient (will receive the email)
#   email_smtp_user          : user used to connect to SMTP server
#   email_smtp_pwd_secret_id : OCID of OCI vault secret containing password used to connect to SMTP server
#   email_smtp_host          : DNS hostname of the SMTP server
#   email_smtp_port          : port of the SMTP server (usually 587)
#
# Author        : Christophe Pauliat
#
# Versions
#    2021-01-06: Initial Version
#    2021-05-05: Improve errors handling
#    2021-10-04: Store SMTP password in OCI Vault as secret
#    2021-10-12: Add HTML mime type in email
#    2021-10-12: Delete expired PARs in bucket
# ----------------------------------------------------------------------------------------------------

# -------- import
import io
import json
import logging
import fdk.response
import datetime
import smtplib
import email.utils
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import oci
import base64

# -------- global variables
access_type              = "ObjectRead"
par_validity_in_days     = 1
email_sender             = ""     
email_sender_name        = ""  
email_recipient          = ""
email_smtp_user          = ""
email_smtp_pwd_secret_id = ""
email_smtp_host          = ""
email_smtp_port          = ""
email_smtp_pwd           = ""
nb_deleted_expired_pars  = 0

# -------- Functions

# ---- send an email
def send_email(l_uri, l_object, l_bucket):

    # The email subject
    email_subject = f"New file available in '{l_bucket}' bucket: {l_object}"

    # Create message container - the correct MIME type is multipart/alternative.
    msg = MIMEMultipart('alternative')
    msg['Subject'] = email_subject
    msg['From']    = email.utils.formataddr((email_sender_name, email_sender))
    msg['To']      = email_recipient

    # The email body for recipients with non-HTML email clients.
    email_body_text = ( f"A new shared file is available in the '{l_bucket}' bucket.\n\n"
                        f"Click the following link to download this file: \n{l_uri}\n"
                        f"(This link is valid for {par_validity_in_days} days)" )

    # The email body for recipients with HTML email clients.
    email_body_html = ( f"<big>A new shared file <span style=\"color:#0000FF\";><b>{l_object}</b></span> is available "
                        f"in the <span style=\"color:#0000FF\";><b>{l_bucket}</b></span> bucket.<br><br>"
                         "Click the following link to download this file: <br>"
                        f"{l_uri}<br><br>"
                        f"Note: This link is valid for {par_validity_in_days} days</big>" )

    # Record the MIME types: text/plain and html
    part1 = MIMEText(email_body_text, 'plain')
    part2 = MIMEText(email_body_html, 'html')

    # Attach parts into message container.
    # According to RFC 2046, the last part of a multipart message, in this case the HTML message, is best and preferred.
    msg.attach(part1)
    msg.attach(part2)

    # send the EMAIL
    server = smtplib.SMTP(email_smtp_host, email_smtp_port)
    server.ehlo()
    server.starttls()
    #smtplib docs recommend calling ehlo() before & after starttls()
    server.ehlo()
    server.login(email_smtp_user, email_smtp_pwd)
    server.sendmail(email_sender, email_recipient, msg.as_string())
    server.close()

# ---- delete expired PARs in the bucket
def delete_expired_pars_in_bucket(l_namespace, l_osclient, l_bucket, l_now):
    # global variables that will be modified in this function
    global nb_deleted_expired_pars

    # Get the preauth requests for the bucket (ignore errors)
    try:
        response = oci.pagination.list_call_get_all_results(l_osclient.list_preauthenticated_requests, namespace_name=l_namespace, bucket_name=l_bucket)
    except:
        return

    # Exit function if no preauth requests found
    if len(response.data) == 0:
        return

    # Delete expired requests (ignore errors)
    for par in response.data:
        if par.time_expires < l_now:
            try:
                oci.object_storage.ObjectStorageClient.delete_preauthenticated_request(l_osclient, namespace_name=l_namespace, bucket_name=l_bucket, par_id=par.id)
                nb_deleted_expired_pars += 1
            except:
                pass

# ---- create the PAR and tries to send it by email
def process_object(bucketName, objectName):            
    signer              = oci.auth.signers.get_resource_principals_signer()
    ObjectStorageClient = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
    namespace           = ObjectStorageClient.get_namespace().data
    now                 = datetime.datetime.now(datetime.timezone.utc)
    exp_time            = now + datetime.timedelta(days=par_validity_in_days)
    par_name            = "PAR_Read_"+objectName
    details             = oci.object_storage.models.PreauthenticatedRequest(access_type=access_type, name=par_name, object_name=objectName, time_expires=exp_time)

    # Delete expired PARs (ignore errors)
    delete_expired_pars_in_bucket (namespace, ObjectStorageClient, bucketName, now)

    # Create PAR and send it by email
    try:
        response = ObjectStorageClient.create_preauthenticated_request (namespace, bucketName, details)
        par = response.data
        uri = f"https://objectstorage.{signer.region}.oraclecloud.com{par.access_uri}"
        try:
            send_email (uri, objectName, bucketName)
            resp = { "success" : "PAR created and sent by email !",
                     "par": uri,
                     "objectName": objectName }
        except Exception as err3:
            resp = { "ERROR3": f"FAILURE during emailing: " + str(err3),
                     "par": uri,
                     "objectName": objectName }
    except Exception as err4:
        resp = { "ERROR4": "FAILURE during PAR creation : " + str(err4) }

    return resp

# ---- get variables from Function configuration
def get_keys_from_fn_config(cfg):
    # global variables that will be modified in this function
    global par_validity_in_days 
    global email_sender             
    global email_sender_name     
    global email_recipient      
    global email_smtp_user     
    global email_smtp_pwd_secret_id      
    global email_smtp_host     
    global email_smtp_port  

    par_validity_in_days     = int(cfg["par_validity_in_days"])
    email_sender             = cfg["email_sender"]        
    email_sender_name        = cfg["email_sender_name"]    
    email_recipient          = cfg["email_recipient"]
    email_smtp_user          = cfg["email_smtp_user"]
    email_smtp_pwd_secret_id = cfg["email_smtp_pwd_secret_id"]
    email_smtp_host          = cfg["email_smtp_host"]
    email_smtp_port          = cfg["email_smtp_port"]

# ---- get SMTP password from OCI Vault secret
def get_smtp_pwd_from_oci_vault_secret():
    # global variable that will be modified in this function
    global email_smtp_pwd    

    signer         = oci.auth.signers.get_resource_principals_signer()
    SecretsClient  = oci.secrets.SecretsClient(config={}, signer=signer)

    response       = SecretsClient.get_secret_bundle(email_smtp_pwd_secret_id)
    secret_bundle  = response.data
    b64_secret_bytes  = secret_bundle.secret_bundle_content.content.encode('ascii')
    b64_message_bytes = base64.b64decode(b64_secret_bytes)
    email_smtp_pwd    = b64_message_bytes.decode('ascii')

# -------- MAIN HANDLER   
def handler(ctx, data: io.BytesIO=None):

    try:
        # get variables from Function configuration
        get_keys_from_fn_config(ctx.Config())

        # get SMTP password from OCI Vault secret
        get_smtp_pwd_from_oci_vault_secret()

        # get bucket and objects Name from JSON input (sent by OCI Event service)
        try:
            body = json.loads(data.getvalue())
            objectName = body["data"]["resourceName"]
            bucketName = body["data"]["additionalDetails"]["bucketName"]

            # process the object: create PAR and send PAR by email
            resp = process_object(bucketName, objectName)

        except Exception as err2:
            resp = { "ERROR2" : "Error in the input JSON data : " + str(err2) }

    except Exception as err1:
        resp = { "ERROR1" : "Missing configuration key : " + str(err1) }

    # add number of deleted expired PARs to result
    resp2 = { "DeletedPARs": nb_deleted_expired_pars }
    resp.update(resp2)
    
    # return result in JSON output
    return fdk.response.Response(
        ctx,
        response_data = json.dumps(resp),
        headers = { "Content-Type": "application/json" }
    )