# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


#resource "random_string" "suffix" {
#  length  = 8
#  special = false
#}



variable  cluster_name {
   type = string
   default = "ass_cluster"
   #default =  "ass-eks-${random_string.suffix.result}"
}


module "vpc" {

	source = "./modules/vpc"
  region = var.region
  cluster_name = var.cluster_name
	
}



module "eks" {

	source = "./modules/eks"
  #region = var.region
  private_subnets_id = module.vpc.private_subnets_id
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
	
}


module "rds" {
  source = "./modules/rds"
  region = var.region
  vpcid = module.vpc.vpc_id
  cluster_name = var.cluster_name
  public_subnets_ids =  module.vpc.public_subnets_ids
  #db_subnet_group_name = module.vpc.db_subnet_group_name
} 





