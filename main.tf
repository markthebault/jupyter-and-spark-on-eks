provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-k8s-cluster"

  cidr = "10.11.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]


  enable_dns_hostnames = true
  enable_dns_support   = true
  default_vpc_enable_dns_hostnames = true


  tags = {
    Owner       = "Chuck Norris"
    Environment = "test"
  }

  vpc_tags = {
    Name = "vpc-k8s-cluster"
  }
}