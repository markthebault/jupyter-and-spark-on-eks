module "my-cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "my-cluster"
  subnets      = "${module.vpc.public_subnets}"
  vpc_id       = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]

  tags = {
    environment = "test"
  }
}