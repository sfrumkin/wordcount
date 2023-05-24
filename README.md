# wordcount


Prerequisites:
- create a bucket in S3 for tfstate
    - update the name in deploy\main.tf
- create a dynamodb for tfstate lock
    - update the name in deploy\main.tf
- create an ECR for putting the docker

To run the terraform:

aws-vault exec --duration=12h sfrumkin22 -- CMD.exe

docker-compose -f deploy/docker-compose.yml run --rm terraform init
docker-compose -f deploy/docker-compose.yml run --rm terraform plan
docker-compose -f deploy/docker-compose.yml run --rm terraform apply
docker-compose -f deploy/docker-compose.yml run --rm terraform destroy
