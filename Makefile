spark_dir=~/workspace/_libs/spark/
repository_url=$(shell aws ecr describe-repositories --repository-names spark --query 'repositories[*].repositoryUri' --output text)
kube_conf_file=./kubeconfig_my-cluster
all:

init:
	terraform init

create-infra:
	terraform apply

build-image:
	cd $(spark_dir) && \
	sh ./bin/docker-image-tool.sh  -m -t spark-cluster build

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

install-helm:
	kubectl --kubeconfig=$(kube_conf_file) apply -f service-account-conf.yml
	helm init --service-account tiller

install-jupyter-chart:
	helm install --name datas ./spark-on-k8s/charts/jupyter-with-spark/ --set serviceAccount=jupyter

jupyter-port-forward:
	kubectl --kubeconfig=$(kube_conf_file) port-forward deployment/datas-jupyter-with-spark 8888:8888