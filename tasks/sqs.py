import os
import json
import boto3

sqs = boto3.client("sqs", region_name=os.getenv("AWS_REGION"))

def send_message(message: dict):
    queue_url = os.environ["SQS_QUEUE_URL"]
    return sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(message),
    )
