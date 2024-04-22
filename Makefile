test:
	docker-compose --file tests/docker-compose-localstack.yml --project-name localstack up --detach
	tflocal init
	tflocal test
	docker-compose --file tests/docker-compose-localstack.yml --project-name localstack down
