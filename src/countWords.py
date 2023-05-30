import json
import base64
from string import punctuation, whitespace
import re
import boto3
import botocore.exceptions
from botocore.exceptions import NoCredentialsError
import uuid
import os

tmpFile="/tmp/results.json"
def upload_to_aws(local_file, s3_file):
    s3 = boto3.client('s3')

    s3.upload_file(local_file, os.environ['BUCKET_NAME'], s3_file)
    url = s3.generate_presigned_url(
        ClientMethod='get_object',
        Params={
            'Bucket': os.environ['BUCKET_NAME'],
            'Key': s3_file
        },
        ExpiresIn=24 * 3600
    )

    print("Upload Successful", url)
    return url

def lambda_handler(event, context):

    file_upload = base64.b64decode(event["body"])
    texts=file_upload.decode('utf-8')
    
    wordsDict={}
    for x in re.split(f'[{punctuation}{whitespace}]', texts):
        xLower=x.strip(punctuation).lower()
        if xLower in wordsDict:
            wordsDict[xLower]+=1
        elif len(xLower)>0:
            wordsDict[xLower]=1

    jsonObj = json.dumps(wordsDict,indent=4)
    with open(tmpFile, "w") as outfile:
        outfile.write(jsonObj)
    try:
        url = upload_to_aws(tmpFile, f'{str(uuid.uuid4())}.txt' )
        return {
            "statusCode": 200,
            "body": json.dumps({'url': url})
        }
    except FileNotFoundError:
        return {
            "statusCode": 404,
            "body": "File Not Found"
        }
    except NoCredentialsError:
       return {
            "statusCode": 401,
            "body": "No Credentials"
        }

