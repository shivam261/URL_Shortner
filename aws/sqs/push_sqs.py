import boto3
import os

sqs = boto3.client("sqs", region_name=os.getenv("AWS_REGION"))

def send_message(message: str):
    queue_url = os.environ["SQS_QUEUE_URL"]
    return sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=message,
    )   