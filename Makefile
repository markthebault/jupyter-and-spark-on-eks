spark_dir=~/workspace/_libs/spark/
repository_url=$(shell aws ecr describe-repositories --repository-names spark --query 'repositories[*].repositoryUri' --output text)
kube_conf_file=$(PWD)/kubeconfig_my-cluster
all: init create-infra build-image push-image-to-ecr install-jupyter

init:
	terraform init

create-infra:
	terraform apply

build-image:
	cd $(spark_dir) && \
	sh ./bin/docker-image-tool.sh -t spark-cluster build

run-proxy:
	kubectl --kubeconfig=$(kube_conf_file) proxy --port=8080


start-shell:
	sh $(spark_dir)bin/pyspark \
		--master k8s://http://127.0.0.1:8080 \
		--deploy-mode client \
		--conf spark.executor.instances=2 \
		--conf spark.executor.cores=1 \
		--conf spark.kubernetes.executor.request.cores=100m \
		--conf spark.kubernetes.container.image=$(repository_url):spark-cluster

push-image-to-ecr:
	#login docker
	@$(shell aws ecr get-login --no-include-email)
	docker tag spark-py:spark-cluster $(repository_url):spark-cluster
	docker push $(repository_url):spark-cluster


install-jupyter:
	kubectl --kubeconfig=$(kube_conf_file) apply -f jupyter.yaml

jupyter-port-forward:
	kubectl --kubeconfig=$(kube_conf_file) port-forward deployment/jupyter 8888:8888

get-pyspark-docker-image:
	@echo $(repository_url):spark-cluster