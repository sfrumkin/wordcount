# wordcount

## Description

 This project exposes 3 APIs:
 - /signup 
    - receives a json containing username, email, password, name
 - /signin 
    - receives a json containing username, password
    - returns in json an id_token to be used as a bearer token in later APIs
 - /countWords 
    - receives a file encoded as base64 in the body
    - returns in json a url to file in S3 bucket containing json of result of each word count

## AWS services:

This project uses the following AWS services:

- API GW
- Cognito
- Lambda functions
- Public S3 bucket

## Prerequisites:

- create a bucket in S3 for tfstate
    - update the name in deploy/main.tf
- create a dynamodb for tfstate lock
    - it must have a partition key named LockID of type String
    - update the name in deploy/main.tf

## To run the terraform:


    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform init
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform fmt
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform validate
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform plan
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform apply
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform destroy

> **_Note:_** Currently the terraform workspace "dev" automatically confirms the sign up of a new user - for automation purposes.  Any other terraform workspace will need to confirm manually the sign up of a new user.

## Postman tests:

- Found at test/WordsCount.postman_collection
- Create a variable named apigwUrl with the value as in the output of the terraform apply command

## Load tests:

- Prerequisite: Install k6
- Update BASE_URL in script below to be as in the output of the terraform apply command
- Use "dev" workspace


        docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform workspace new dev
        docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform workspace select dev

- Run k6

        k6 run test\k6-load.js


Thanks

