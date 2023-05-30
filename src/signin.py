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

def initiate_auth(client, username, password):
    secret_hash = get_secret_hash(username)
    try:
      resp = client.admin_initiate_auth(
                 UserPoolId=USER_POOL_ID,
                 ClientId=CLIENT_ID,
                 AuthFlow='ADMIN_NO_SRP_AUTH',
                 AuthParameters={
                     'USERNAME': username,
                     'SECRET_HASH': secret_hash,
                     'PASSWORD': password,
                  },
                ClientMetadata={
                  'username': username,
                  'password': password,
              })
    except client.exceptions.NotAuthorizedException:
        return None, "The username or password is incorrect"
    except client.exceptions.UserNotConfirmedException:
        return None, "User is not confirmed"
    except Exception as e:
        return None, e.__str__()
    return resp, None

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    
    body = json.loads(event['body']) 
    
    for field in ["username", "password"]:
        if body.get(field) is None:
            return {"statusCode": 400, 
                "body": f"{field} is required"}    
    
    username = body['username']
    password = body['password']
    
    resp, msg = initiate_auth(client, username, password)
    if msg != None:
        return {"statusCode": 401, 
                "body": msg}
    if resp.get("AuthenticationResult"):
        return {"statusCode": 200, 
                "body": json.dumps({
                "id_token": resp["AuthenticationResult"]["IdToken"],
                "refresh_token": resp["AuthenticationResult"]["RefreshToken"],
                "access_token": resp["AuthenticationResult"]["AccessToken"],
                "expires_in": resp["AuthenticationResult"]["ExpiresIn"],
                "token_type": resp["AuthenticationResult"]["TokenType"]
                })}
                
    return {"statusCode": 400, 
            "body": 'Some error'}
