# terraform-aws-ec2-basic

Terraform module to run a basic ec2 on AWS with some basic defaults.

## Features

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

## Terraform Versions

For Terraform v0.12.0+

## Usage

```
module "this" {
    source = "github.com/robc-io/terraform-aws-ec2-basic"
    name = "stuff"
}
```
## Examples

- [defaults](https://github.com/robc-io/terraform-aws-ec2-basic/tree/master/examples/defaults)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ami\_id | n/a | `string` | `""` | no |
| create | Boolean to determine if you should create the instance or destroy all associated resources | `bool` | `true` | no |
| create\_eip | Optional ability to create elastic IP | `bool` | `false` | no |
| ebs\_prevent\_destroy | n/a | `bool` | `false` | no |
| ebs\_volume\_id | The volume id of the ebs volume to mount | `string` | `""` | no |
| ebs\_volume\_size | n/a | `number` | `0` | no |
| ec2\_prevent\_destroy | n/a | `bool` | `false` | no |
| egress\_rules | From terraform-aws-security-group module | `list(string)` | <pre>[<br>  "all-all"<br>]</pre> | no |
| eip\_prevent\_destroy | n/a | `bool` | `false` | no |
| iam\_managed\_policies | List of managed policies to add to instance profile.  Instance profile must not be specified as it has precendance | `list(string)` | `[]` | no |
| ingress\_cidr\_blocks | From terraform-aws-security-group module | `list(string)` | `[]` | no |
| ingress\_rules | From terraform-aws-security-group module | `list(string)` | `[]` | no |
| ingress\_with\_cidr\_blocks | From terraform-aws-security-group module | `list(map(string))` | `[]` | no |
| instance\_profile\_id | n/a | `string` | `""` | no |
| instance\_type | n/a | `string` | `"m4.large"` | no |
| json\_policy | A user supplied policy to add to the instance | `string` | `""` | no |
| json\_policy\_name | The name of the user defined policy | `string` | `""` | no |
| key\_name | If this is supplied, it takes precidence | `string` | `""` | no |
| local\_public\_key | n/a | `string` | `""` | no |
| monitoring | Send logs and metrics to cloudwatch | `bool` | `true` | no |
| name | The name to be used in tags | `any` | n/a | yes |
| root\_volume\_size | n/a | `number` | `8` | no |
| subnet\_id | Supply both vpc\_id and subnet\_id or deploy into default vpc | `string` | `""` | no |
| tags | Tags that are appended | `map(string)` | `{}` | no |
| user\_data | n/a | `string` | `""` | no |
| user\_data\_script | n/a | `string` | `"user_data_ubuntu_ebs.sh"` | no |
| volume\_path | n/a | `string` | `"/dev/sdf"` | no |
| vpc\_id | Supply both vpc\_id and subnet\_id or deploy into default vpc | `string` | `""` | no |
| vpc\_security\_group\_ids | A list of provided descurity group IDs | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| eip\_id | n/a |
| instance\_id | n/a |
| instance\_profile\_id | n/a |
| key\_name | n/a |
| private\_ip | n/a |
| public\_ip | n/a |
| volume\_path | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests.

```
go mod tidy
make test
```

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.