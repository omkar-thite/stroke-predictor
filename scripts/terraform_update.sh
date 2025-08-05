cd ../infrastructure
terraform init
sleep 1
terraform plan --var-file=vars/prod.tfvars -out=tfplan
sleep 1
terraform apply --var-file=vars/prod.tfvars tfplan