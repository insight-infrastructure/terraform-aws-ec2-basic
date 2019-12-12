# terraform-aws-icon-p-rep-node

Terraform module to run a basic ec2 on AWS with some nice options 

### Components 

- ec2
    - Basic options exposed 
- Security group
	- Exposes the official [aws-terraform-security-groups](https://github.com/terraform-aws-modules/terraform-aws-security-group)
- VPC
	- If no VPC is supplied, deploys in default VPC 
- EBS 
	- Create volume and mount or not 
- IAM 
	- Able to provide custom policy or managed policy for instance profile 
- Elastic IP 
	- Optional create 
- AMI
	- Supply AMI ID or default to ubuntu 
- Key pair 
	- Supply public key or just keyname 
- User data 
	- You are going to want to override

