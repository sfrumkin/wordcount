import boto3
import botocore.exceptions
import hmac
import hashlib
import base64
import json
import os

USER_POOL_ID = os.environ['COGNITO_USER_POOL_ID']
CLIENT_ID = os.environ['COGNITO_POOL_CLIENT_ID']
CLIENT_SECRET = os.environ['COGNITO_POOL_CLIENT_SECRET']


def get_secret_hash(username):
    msg = username + CLIENT_ID
    dig = hmac.new(str(CLIENT_SECRET).encode('utf-8'),
                   msg=str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2


def create_answer(status_code, message):
    return {
        "statusCode": status_code,
        "body": message
    }


def lambda_handler(event, context):
    body = json.loads(event['body'])

    for field in ["username", "email", "password", "name"]:
        if not body.get(field):
            return create_answer(400, f'Missing field: {field}')

    username = body['username']
    email = body["email"]
    password = body['password']
    name = body["name"]

    client = boto3.client('cognito-idp')

    try:
        client.sign_up(
            ClientId=CLIENT_ID,
            SecretHash=get_secret_hash(username),
            Username=username,
            Password=password,
            UserAttributes=[
                {
                    'Name': "name",
                    'Value': name
                },
                {
                    'Name': "email",
                    'Value': email
                }
            ],
            ValidationData=[
                {
                    'Name': "email",
                    'Value': email
                },
                {
                    'Name': "custom:username",
                    'Value': username
                }
            ])
    except client.exceptions.UsernameExistsException:
        return create_answer(400, "This username already exists")
    except client.exceptions.InvalidPasswordException:
        return create_answer(401, "Password should have Caps, Special chars, Numbers")
    except client.exceptions.UserLambdaValidationException:
        return create_answer(400,str(e))
    except Exception as e:
        return create_answer(400, str(e))

    return create_answer(201, "Please confirm your signup, check Email for validation code")

