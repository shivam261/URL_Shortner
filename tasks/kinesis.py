import os
import json
import boto3

kinesis = boto3.client("kinesis", region_name=os.getenv("AWS_REGION"))

def put_record(stream_name: str, data: dict, partition_key: str):
    return kinesis.put_record(
        StreamName=stream_name,
        Data=json.dumps(data),
        PartitionKey=partition_key,
    )
