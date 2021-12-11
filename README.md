# challenge-1

## 3 tier arch

1) Backend for teraform statefile is a S3 bucket which is not part of the 3 tier architecture module, I wanted it to be seperate so I can persist the statefile even when the modules are destroyed. 

``` 
cd backend
terraform init
terrafor apply
```

2) Actual resouces can be deployed right from the project folder, I used `Terraform v1.0.11` for this deployment. 

```
terraform init
terraform plan
terraform apply -auto-approve
```
