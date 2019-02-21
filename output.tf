output "spark_registry_uri" {
  value = "${aws_ecr_repository.spark_img.repository_url}"
}

output "jupyter_registry_uri" {
  value = "${aws_ecr_repository.jupyter_img.repository_url}"
}

