

output "region" {
  description = "AWS region"
  value       = var.region
}

output cluster_name{
  value = module.eks.cluster_name
}


output vpc_id{
  value = module.vpc.vpc_id
}


output cluster_endpoint{
  value = module.eks.cluster_endpoint
}


output rds_dns_name {
  value = module.rds.rds_dns_name
}



