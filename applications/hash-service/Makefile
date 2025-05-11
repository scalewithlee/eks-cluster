.PHONY: build run push test

build:
	docker build -t hash-service .

run: build
	docker run -p 8080:8080 hash-service

push:
	aws ecr get-login-password --region $${AWS_REGION} | docker login --username AWS --password-stdin $${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_REGION}.amazonaws.com
	docker tag hash-service:latest $${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_REGION}.amazonaws.com/app-images:latest
	docker push $${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_REGION}.amazonaws.com/hash-service:latest
