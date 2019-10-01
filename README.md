# terraform-aws-icon-p-rep-node

Terraform module to run a public representative node for the ICON Blockchain. Module is intended to be run via 
Terragrunt, a Terraform wrapper.


### Components 

- ec2
    - Bootstraps docker-compose through user-data 
- spot instance request 
    - About to decou

### user-data 

- updates / upgrades 
- python 
    - rm? - Could use for an additional step 
- docker 
- mounts data volume 
- cloudwatch agent 
    - pulls config from bucket 
- prints docker-compose 
- TODO:
    - keystore
    - run docker-compose 

### Secrets 

TODO

Right now we do not have an adequate secrets storing solution.  Until we get Hashicorp vault running, we need a script 
that scp's the keystore over from a provisioning step (Soe San - Insight), a null_resource (Rob - Insight). 
We are working on getting vault running though so it is a judgement call. 

### IAM Roles in Profile 

- EBS mount policy 
- Cloudwatch logs put 
- S3 read 


### What this doesn't include 

- Does not include VPC or any ALB 
- Does not include security groups as we will be building in various features to have automated IP whitelisting 
updates based on the P-Rep IP list - https://download.solidwallet.io/conf/prep_iplist.json
- Does not include any logging or alarms as this will be custom     
