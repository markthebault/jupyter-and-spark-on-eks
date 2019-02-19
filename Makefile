spark_dir=~/workspace/_libs/spark/
spark_repository_ecr=$(shell aws ecr describe-repositories --repository-names spark --query 'repositories[*].repositoryUri' --output text)
kube_conf_file=$(PWD)/kubeconfig_my-cluster

all: init create-infra build-image push-image-to-ecr install-jupyter get-jupyter-token

init:
	terraform init

create-infra:
	terraform apply

build-image:
	cd $(spark_dir) && \
	sh ./bin/docker-image-tool.sh -t spark-cluster build

run-proxy:
	kubectl --kubeconfig=$(kube_conf_file) proxy --port=8080

push-image-to-ecr:
	#login docker
	@$(shell aws ecr get-login --no-include-email)
	docker tag spark-py:spark-cluster $(spark_repository_ecr):spark-cluster
	docker push $(spark_repository_ecr):spark-cluster

install-jupyter:
	kubectl --kubeconfig=$(kube_conf_file) apply -f jupyter.yaml

jupyter-port-forward:
	kubectl --kubeconfig=$(kube_conf_file) port-forward deployment/jupyter 8888:8888

get-pyspark-docker-image:
	@echo $(spark_repository_ecr):spark-cluster

get-jupyter-token:
	@kubectl --kubeconfig=$(kube_conf_file) logs deployment/jupyter | grep token