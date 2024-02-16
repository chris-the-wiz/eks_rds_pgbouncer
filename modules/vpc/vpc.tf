
variable "region" { type = string }
variable "cluster_name"{ type = string }

provider "aws" { region = var.region }

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "assvpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  


}



# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}



/*
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet_group"
  subnet_ids = data.aws_subnets.public_subnets.ids
  description = "Subnet group for RDS in my VPC"
}
*/

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = "v1.26.9-eksbuild.2"
}

resource "aws_eks_addon" "core_dns" {
  cluster_name = var.cluster_name
  addon_name        = "coredns"
  addon_version     = "v1.9.3-eksbuild.7"
}



