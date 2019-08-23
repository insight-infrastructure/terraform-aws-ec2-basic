data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

terraform {
  required_version = ">= 0.12"
}

locals {
  name = var.resource_group
  common_tags = {
    "Terraform"   = true
    "Environment" = var.environment
  }

  tags                   = merge(var.tags, local.common_tags)
  terraform_state_bucket = "terraform-states-${data.aws_caller_identity.this.account_id}"
  terraform_state_region = var.terraform_state_region
  //  volume_path = "${split(".", var.instance_type)[0] == "c5"}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "this" {
  vpc      = true
  instance = aws_instance.this.id

  lifecycle {
    prevent_destroy = "false"
  }
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.azs[0]
  size              = var.ebs_volume_size
  type              = "gp2"
  tags = merge(
    local.tags,
    {
      Name = "ebs-main"
    },
  )

  lifecycle {
    prevent_destroy = "false"
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = data.template_file.user_data.rendered
  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.this.id
  subnet_id = var.subnet_id
  security_groups = var.security_groups

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/data/user_data_ubuntu_ebs.sh")
}

resource "aws_volume_attachment" "this" {
  device_name = var.volume_path
//  volume_id   = data.terraform_remote_state.ebs.outputs.volume_id

  volume_id = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id

  force_detach = true
}

resource "aws_iam_instance_profile" "this" {
  name = "test_profile"
  role = aws_iam_role.this.name
}

data "template_file" "ebs_mount_policy" {
  template = file("${path.module}/data/ebs_mount_policy.json")
//TODO: IAM lockdown
  vars = {
//    file_system_id = data.terraform_remote_state.efs.outputs.file_system_id
//    account_id     = data.aws_caller_identity.this.account_id
//    region         = data.aws_region.current.name
  }
}


resource "aws_iam_policy" "ebs_mount_policy" {
  name   = "${title(local.name)}EBSPolicy"
  policy = data.template_file.ebs_mount_policy.rendered
}

resource "aws_iam_role_policy_attachment" "efs_mount_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ebs_mount_policy.arn
}

resource "aws_iam_role_policy_attachment" "ebs_mount_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ebs_mount_policy.arn
}

resource "aws_iam_role" "this" {
  name               = "${title(local.name)}EFSRole"
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
}
