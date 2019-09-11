data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

terraform {
  required_version = ">= 0.12"
}

locals {
  name = var.resource_group
  common_tags = {
    "Name" = local.name
    "Terraform" = true
    "Environment" = var.environment
  }

  tags = merge(var.tags, local.common_tags)
}

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

resource "aws_eip" "this" {
  vpc = true
  lifecycle {
    prevent_destroy = "false"
  }
}

resource "aws_eip_association" "this" {
  allocation_id = aws_eip.this.id
  instance_id = var.spot_price == 0 ? aws_instance.this.*.id[0] : module.instance_id.stdout
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.azs[0]
  size = var.ebs_volume_size
  type = "gp2"
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

resource "aws_volume_attachment" "this" {
  device_name = var.volume_path

  volume_id = aws_ebs_volume.this.id
  instance_id = var.spot_price == 0 ? aws_instance.this.*.id[0] : module.instance_id.stdout

  force_detach = true

  depends_on = [null_resource.wait_on_startup]
}

data "template_file" "user_data" {
  template = file("${path.module}/data/user_data_ubuntu_ebs.sh")

  vars = {
    log_config_bucket = var.log_config_bucket
    log_config_key = var.log_config_key
  }
}

resource "aws_instance" "this" {
  count = var.spot_price == 0 ? 1 : 0

  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = data.template_file.user_data.rendered
  key_name = var.key_name

  iam_instance_profile = var.instance_profile_id
  subnet_id = var.subnet_id
  security_groups = var.security_groups

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
    delete_on_termination = true
  }
}

resource "aws_spot_instance_request" "this" {
  count = var.spot_price != 0 ? 1 : 0
  wait_for_fulfillment = true

  spot_price = var.spot_price

  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = data.template_file.user_data.rendered
  key_name = var.key_name

  iam_instance_profile = var.instance_profile_id
  subnet_id = var.subnet_id
  security_groups = var.security_groups

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
    delete_on_termination = true
  }
}

module "instance_id" {
  source = "matti/resource/shell"
  command = var.spot_price == 0 ? "echo no-waiting" : format("aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids %s && aws ec2 describe-spot-instance-requests --spot-instance-request-ids %s | jq -r '.SpotInstanceRequests[].InstanceId'", aws_spot_instance_request.this.*.id[0], aws_spot_instance_request.this.*.id[0])
}

resource "null_resource" "wait_on_startup" {
//This will fail on windows as it has a different sleep command - USE WSL ALWAYS
  provisioner "local-exec" {
    command = "sleep 20"
  }
  depends_on = [module.instance_id]
}