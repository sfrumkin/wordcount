# wordcount


Prerequisites:
- create a bucket in S3 for tfstate
    - update the name in deploy\main.tf
- create a dynamodb for tfstate lock
    - it must have a partition key named LockID of type String
    - update the name in deploy\main.tf
- create an ECR for putting the docker

To run the terraform:

aws-vault exec --duration=12h sfrumkin22 -- CMD.exe

docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform init
docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform plan
docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform apply
docker-compose -f deploy/docker-compose.yml run  --workdir /infra/deploy --rm terraform destroy
