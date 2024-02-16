# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0



output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets_id"{
  value =  module.vpc.private_subnets
}



output "public_subnets_ids"{
  value =  module.vpc.public_subnets
}


#output "db_subnet_group_name" {
#  value = aws_db_subnet_group.my_db_subnet_group.name
#}