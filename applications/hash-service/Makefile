.PHONY: build build-multiarch run push test create-builder

# Set up buildx builder for multi-architecture builds
create-builder:
	docker buildx create --name multiplatform-builder --use || true
	docker buildx inspect --bootstrap

# Build for current architecture (faster for local testing)
build:
	docker build -t hash-service .

# Build for both amd64 and arm64
build-multiarch: create-builder
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t hash-service:latest \
		--load .

run: build
	docker run -p 80:80 hash-service

# Build and push multi-architecture image to ECR
push: build-multiarch
	AWS_ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text --no-cli-pager) && \
	AWS_REGION="us-west-2" && \
	APP="hash-service" && \
	aws ecr get-login-password --region $$AWS_REGION | docker login --username AWS --password-stdin $$AWS_ACCOUNT_ID.dkr.ecr.$$AWS_REGION.amazonaws.com && \
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t $$AWS_ACCOUNT_ID.dkr.ecr.$$AWS_REGION.amazonaws.com/$$APP:latest \
		--push .

deploy:
	export AWS_ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text --no-cli-pager) && \
	export AWS_REGION="us-west-2" && \
	envsubst < kubernetes/deployment.yaml | kubectl apply -f - && \
	kubectl apply -f kubernetes/service.yaml

undeploy:
	kubectl delete -f kubernetes/service.yaml
	kubectl delete deployment hash-service

test:
	curl -X POST -H "Content-Type: application/json" -d '{"message":"Hello Rigetti!"}' http://localhost:80/store
	@echo ""
	curl -X POST -H "Content-Type: application/json" -d '{"hash":"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"}' http://localhost:80/get
