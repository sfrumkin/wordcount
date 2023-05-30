# wordcount


Prerequisites:
- create a bucket in S3 for tfstate
    - update the name in deploy\main.tf
- create a dynamodb for tfstate lock
    - it must have a partition key named LockID of type String
    - update the name in deploy\main.tf

To run the terraform:

    aws-vault exec --duration=12h sfrumkin22 -- CMD.exe

    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform init
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform fmt
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform validate
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform plan
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform apply
    docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform destroy

To run load test:

- Prerequisite: Install k6
- Update BASE_URL in script below to be as in  the output of the terraform apply command

Run the following

    k6 run test\k6-load.js

Thanks