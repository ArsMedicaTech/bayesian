include .env

docker-create:
	aws ecr create-repository --repository-name $(BAYESIAN_IMAGE) --region us-east-1 || true


auth:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(DOCKER_REGISTRY)


BAYESIAN_BUILD_ARGS=

bayesian-docker:
	docker build -t $(DOCKER_REGISTRY)/$(BAYESIAN_IMAGE):$(BAYESIAN_VERSION) $(BAYESIAN_BUILD_ARGS) -f ./Dockerfile .
	docker push $(DOCKER_REGISTRY)/$(BAYESIAN_IMAGE):$(BAYESIAN_VERSION)
	kubectl rollout restart deployment $(BAYESIAN_DEPLOYMENT) --namespace=$(NAMESPACE)
