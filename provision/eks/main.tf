provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"

  name                 = var.aws_vpc_name
  cidr                 = "172.17.0.0/16"
  azs                  = var.aws_availability_zones
  private_subnets      = ["172.17.0.0/20", "172.17.16.0/20"]
  public_subnets       = ["172.17.32.0/20", "172.17.48.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = var.aws_tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  cluster_name              = var.eks_cluster_name
  cluster_version           = "1.20"
  vpc_id                    = module.vpc.vpc_id
  subnets                   = module.vpc.private_subnets
  cluster_service_ipv4_cidr = "172.18.0.0/16"
  enable_irsa               = true
  tags                      = var.aws_tags
  manage_aws_auth           = false

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    core = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 0

      instance_types = ["t3.2xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }
}
