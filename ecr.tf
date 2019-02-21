resource "aws_ecr_repository" "spark_img" {
  name = "spark"
}
resource "aws_ecr_repository" "jupyter_img" {
  name = "jupyter"
}
