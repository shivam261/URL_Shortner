import os
import json
import boto3

sns = boto3.client("sns", region_name=os.getenv("AWS_REGION"))

def publish_message(topic_arn: str, message: dict, subject: str = None):
    kwargs = {"TopicArn": topic_arn, "Message": json.dumps(message)}
    if subject:
        kwargs["Subject"] = subject
    return sns.publish(**kwargs)
