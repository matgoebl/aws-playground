import logging
import os
import json
import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Called {event} with {context}")

    data = { "function_name": context.function_name, "context": str(context), "event": str(event) }
    jsondata = json.dumps(data)

    s3 = boto3.resource('s3')
    # object = s3.Object(os.environ['s3_bucket'], 'status.json')
    # object.put(Body=jsondata, Metadata={'Content-Type': 'application/json'})
    object = s3.Object(os.environ['s3_bucket'], 'index.html')
    # x="<!DOCTYPE html><html><body>"
    object.put(Body=jsondata, ContentType='text/html', ACL = 'public-read') #Metadata={'Content-Type': 'text/html'})

    logger.info(f"Output is {jsondata}")

    return data

    # return {
    #     "statusCode": 200,
    #     "headers": {
    #         "Content-Type": "application/json"
    #     },
    #     "body": json.dumps({
    #         "Region ": json_region
    #     })
    # }
