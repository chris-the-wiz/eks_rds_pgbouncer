

TF based on https://github.com/Wasi87/learn-terraform-provision-eks-cluster 

Docker file is a mix of: https://github.com/shahradelahi/docker-pgbouncer and some other that I do not remember... sorry

Changes:
1. turned into modules
2. added rds
3. added Dockerfile which creates an alpine linux image containing all you need for ssh and pgbouncer debugging
  (for production you may want to remove the postgres, change passwords etc.)

USAGE:

1. upload the image to ECR manually 
2. update the address to the image in the configuartion
3. run deploy.sh (several times because timeouts)

