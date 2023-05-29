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
        msg = str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2

def lambda_handler(event, context):
    body = json.loads(event['body']) 
    for field in ["username", "email", "password", "name"]:        
        if not body.get(field):
            print('Missing field')
            return {"statusCode": 400, 
                "body": "Missing field: " + field}
    username = body['username']
    email = body["email"]
    password = body['password']
    name = body["name"]
    client = boto3.client('cognito-idp')
    try:
        resp = client.sign_up(
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
    except client.exceptions.UsernameExistsException as e:
        print(str(e))
        return {"statusCode": 400, 
            "body": "This username already exists"
            }
    except client.exceptions.InvalidPasswordException as e:
        print(str(e))            
        return {"statusCode": 401, 
            "body": "Password should have Caps,\
                        Special chars, Numbers"
                        }
    except client.exceptions.UserLambdaValidationException as e:
        print(str(e))
        return {"statusCode": 400, 
            "body": "Email already exists"}
    
    except Exception as e:
        print(str(e))
        return {"statusCode": 400, 
                "body": str(e)
                }
    
    print('status 200')
    return {"statusCode": 200,
            "body": "Please confirm your signup, \
                        check Email for validation code"
            }