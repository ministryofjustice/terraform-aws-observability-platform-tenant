docker-compose --file docker-compose-localstack.yml --project-name localstack up --detach

tflocal plan -compact-warnings

tflocal apply -auto-approve -compact-warnings

awslocal s3 ls
