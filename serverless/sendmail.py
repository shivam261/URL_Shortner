import os
import boto3

ses = boto3.client("ses", region_name=os.getenv("AWS_REGION"))
SENDER_EMAIL = os.environ["SES_SENDER_EMAIL"]

def handler(event, context):
    recipient = event["email"]
    subject = event["subject"]
    body = event["content"]

    return ses.send_email(
        Source=SENDER_EMAIL,
        Destination={"ToAddresses": [recipient]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}},
        },
    )
