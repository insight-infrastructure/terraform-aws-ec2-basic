data "aws_caller_identity" "this" {}
data "aws_region" "current" {}
terraform {
  required_version = ">= 0.12"
}

locals {
  name = var.name
  common_tags = {
    "Name" = local.name
    "Terraform" = true
    "Region" = data.aws_region.current.name
  }

  tags = merge(var.tags, local.common_tags)
}

resource "random_pet" "this" {}

##########
# instance
##########

resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  instance_type = var.instance_type

  user_data = var.user_data == "" ? data.template_file.user_data.rendered : var.user_data

  subnet_id = var.subnet_id == "" ? tolist(data.aws_subnet_ids.default_subnets.ids)[0] : var.subnet_id
//  vpc_security_group_ids = concat([module.security_group.this_security_group_id], var.vpc_security_group_ids)
  vpc_security_group_ids = var.vpc_security_group_ids
  security_groups = var.vpc_security_group_ids == [] ? module.security_group.this_security_group_id : []

  ami = var.ami_id == "" ? data.aws_ami.ubuntu.id : var.ami_id

  monitoring = var.monitoring

  iam_instance_profile = var.instance_profile_id == "" ? aws_iam_instance_profile.this[0].id : var.instance_profile_id
  key_name = var.key_name == "" ? aws_key_pair.this[0].key_name : var.key_name

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
    delete_on_termination = true
  }

  //  lifecycle {
  //  https://github.com/hashicorp/terraform/issues/22544
  //    prevent_destroy = var.ec2_prevent_destroy
  //  }

  tags = local.tags
}

###########
# user-data
###########

data "template_file" "user_data" {
  template = file("${path.module}/data/${var.user_data_script}")
}

#############
# default vpc
#############

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default.id
}

#################
# security groups
#################

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  create = var.vpc_security_group_ids == [] && var.create ? true : false

  name = var.name
  description = "Default security group if no security groups ids are supplied"
  vpc_id = var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules = var.egress_rules

  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
}

############
# elastic ip
############

resource "aws_eip" "this" {
  count = var.create_eip && var.create ? 1 : 0

  vpc = true

  lifecycle {
    prevent_destroy = false
  }

  tags = local.tags
}

resource "aws_eip_association" "this" {
  count = var.create_eip && var.create ? 1 : 0

  allocation_id = aws_eip.this.*.id[count.index]
  instance_id = aws_instance.this.*.id[0]
}

#############
# default AMI
#############

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }

  owners = [
    "099720109477"]
  # Canonical
}

############
# ebs volume
############

resource "aws_ebs_volume" "this" {
  count = var.ebs_volume_size > 0 && var.create ? 1 : 0

  availability_zone = aws_instance.this.*.availability_zone[0]

  size = var.ebs_volume_size
  type = "gp2"

  //  lifecycle {
  //  https://github.com/hashicorp/terraform/issues/22544
  //    prevent_destroy = var.ebs_prevent_destroy
  //  }

  tags = local.tags
}

resource "aws_volume_attachment" "this" {
  count = var.ebs_volume_size > 0 && var.create ? 1 : 0

  device_name = var.volume_path

  volume_id = var.ebs_volume_id == "" ? aws_ebs_volume.this[0].id : var.ebs_volume_id

  instance_id = aws_instance.this.*.id[0]
  force_detach = true
}

######################
# IAM instance profile
######################

resource "aws_iam_role" "this" {
  count = var.instance_profile_id == "" && var.create ? 1 : 0
  name = "${title(local.name)}-${random_pet.this.id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_instance_profile" "this" {
  count = var.instance_profile_id == "" && var.create ? 1 : 0

  name = "${title(local.name)}InstanceProfile-${random_pet.this.id}"
  role = aws_iam_role.this[0].name
}

#########################
# Additional IAM policies
#########################

resource "aws_iam_role_policy_attachment" "managed_policy" {
  count = var.instance_profile_id == "" && var.create ? length(var.iam_managed_policies) : 0
  role = aws_iam_role.this[0].id

  policy_arn = "arn:aws:iam::aws:policy/${var.iam_managed_policies[count.index]}"
}

resource "aws_iam_policy" "json_policy" {
  count = var.instance_profile_id == "" && var.json_policy_name != "" && var.create ? 1 : 0
  name = var.json_policy_name
  description = "A user defined policy for the instance"

  policy = var.json_policy
}

resource "aws_iam_role_policy_attachment" "json_policy" {
  count = var.instance_profile_id == "" && var.json_policy_name != "" && var.create ? 1 : 0
  role = aws_iam_role.this[0].id

  policy_arn = aws_iam_policy.json_policy[0].arn
}

#########
# keypair
#########

resource "aws_key_pair" "this" {
  count = var.key_name == "" && var.create ? 1 : 0
  key_name = "${local.name}-${random_pet.this.id}"
  public_key = file(var.local_public_key)
}

