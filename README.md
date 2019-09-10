# terraform-aws-icon-p-rep-node

Terraform module to run a public representative node for the ICON Blockchain. Module is intended to be run via 
Terragrunt, a Terraform wrapper.


### Components 

- ec2
    - Bootstraps docker-compose through user-data 
- spot instance request 


### IAM Roles in Profile 

- EBS mount policy 
    - Done 
- Cloudwatch logs put 
    - Needed 

   

### What this doesn't include 

- Does not include VPC or any ALB 
- Does not include security groups as we will be building in various features to have automated IP whitelisting 
updates based on the P-Rep IP list - https://download.solidwallet.io/conf/prep_iplist.json
- Does not include any logging or alarms as this will be custom     

