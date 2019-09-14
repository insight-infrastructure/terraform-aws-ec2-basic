variable "region" {
  description = "The region you are deploying into"
}

variable "environment" {
  description = "The environment that generally corresponds to the account you are deploying into."
}

variable "resource_group" {
  description = "The grouping that is conventionally used to name resources"
}

variable "tags" {
  description = "Tags that are appended"
  type        = map(string)
}

variable "terraform_state_region" {
  description = "AWS region used for Terraform states"
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_type" {}
variable "root_volume_size" {}
variable "volume_path" {}

//variable "local_private_key" {} # TODO Only needed for remote calls but commented out now

variable "azs" {
  description = "The availablity zones to deploy each ebs volume into."
  type        = list(string)
}

variable "ebs_volume_size" {}

//-----

variable "key_name" {}
variable "public_key" {}
//TODO: Hide this^^^

variable "security_groups" {
  type = list
}
variable "subnet_id" {}

//----------

variable "instance_profile_id" {}

variable "log_config_bucket" {}
variable "log_config_key" {}
