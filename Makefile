test:
	docker-compose --file tests/docker-compose-localstack.yml --project-name localstack up --detach
	tflocal init
	tflocal test -compact-warnings
	docker-compose --file tests/docker-compose-localstack.yml --project-name localstack down
