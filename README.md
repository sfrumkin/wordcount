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

## Prerequisites for terraform backend:

- create a bucket in S3 for tfstate
    - update the name in deploy/main.tf
- create a dynamodb for tfstate lock
    - it must have a partition key named LockID of type String
    - update the name in deploy/main.tf

## To run the terraform:

- Running terraform installed on PC


        terraform init
        terraform fmt
        terraform validate
        terraform plan
        terraform apply
        terraform destroy


- Alternatively you can run terraform from docker (will use specific version):


        docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform


> **_Note:_** Currently the terraform workspace "dev" automatically confirms the sign up of a new user - for automation purposes.  Any other terraform workspace will need to confirm manually the sign up of a new user.

## Postman tests:

- Found at test/WordsCount.postman_collection
- Create a variable named apigwUrl with the value as in the output of the terraform apply command

## Shell script running curl commands:

- will work on dev workspace out of the box.  On any other workspace, will need to confirm the emaii manually (press the link) and then re-run


        cd test
        sh testAPIs.sh


## Load tests:

- Prerequisite: Install k6
- Use "dev" workspace


        terraform workspace new dev
        terraform workspace select dev

- Run k6 in shell

        k6 run test/k6-load.js --env BASE_URL=`cd deploy && terraform output --raw base_url`


Thanks

