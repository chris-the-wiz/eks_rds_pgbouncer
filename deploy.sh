#!/bin/bash

if [[ "$1" == "--unroll" ]]; then
    echo "The script was launched with the --unroll parameter."
    terraform apply --destroy  --auto-approve



else
  echo "Roll out installation"
  echo "Planning..."
  terraform plan -out ass
   echo "Applying..."
  terraform apply --auto-approve "ass" 
  if ! [ $? -eq 0 ]; then
    echo "Terraform apply failed. Rinse'n'repeat."
else
    echo "Terraform apply completed successfully"
    aws eks update-kubeconfig --name ass_cluster
    kubectl apply -f statefulset_generated.yaml
fi
  # if successful
  



fi
