variable "name" {
  description = "The name to be used in tags"
}

variable "tags" {
  description = "Tags that are appended"
  type        = map(string)
}

variable "create" {
  type = bool
  default = true
  description = "Boolean to determine if you should create the instance or destroy all associated resources"
}

##########
# instance
##########

variable "instance_type" {
  type = string
  default = "m4.large"
}

variable "root_volume_size" {
  type = number
  default = 8
}

variable "volume_path" {
  type = string
  default = "/dev/sdf"
}

variable "monitoring" {
  type = bool
  default = true
  description = "Send logs and metrics to cloudwatch"
}

variable "ec2_prevent_destroy" {
  type = bool
  default = false
}

variable "eip_prevent_destroy" {
  type = bool
  default = false
}

###########
# user-data
###########

variable "user_data_script" {
  type = string
  default = "user_data_ubuntu_ebs.sh"
}

variable "user_data" {
  type = string
  default = ""
}

#####
# vpc
#####

variable "vpc_id" {
  type = string
  default = ""
  description = "Supply both vpc_id and subnet_id or deploy into default vpc"
}

variable "subnet_id" {
  type = string
  default = ""
  description = "Supply both vpc_id and subnet_id or deploy into default vpc"
}

############
# elastic ip
############

variable "create_eip" {
  type = bool
  default = false
  description = "Optional ability to create elastic IP"
}

#################
# security groups
#################

variable "vpc_security_group_ids" {
  type = list(string)
  default = [""]
  description = "A list of provided descurity group IDs"
}

variable "egress_rules" {
  default = ["all-all"]
  type = list(string)
  description = "From terraform-aws-security-group module"
}

variable "ingress_cidr_blocks" {
  type = list(string)
  default = []
  description = "From terraform-aws-security-group module"
}

variable "ingress_with_cidr_blocks" {
  default = []
  type = list(map(string))
  description = "From terraform-aws-security-group module"
}

variable "ingress_rules" {
  type = list(string)
  default = []
  description = "From terraform-aws-security-group module"
}

#####
# AMI
#####

variable "ami_id" {
  type = string
  default = ""
}

############
# ebs volume
############

variable "ebs_volume_id" {
  type = string
  default = ""
  description = "The volume id of the ebs volume to mount"
}

variable "ebs_volume_size" {
  type = number
}

variable "ebs_prevent_destroy" {
  type = bool
  default = false
}

#########
# keypair
#########

variable "key_name" {
  type = string
  default = ""
  description = "If this is supplied, it takes precidence"
}

variable "local_public_key" {
  type = string
  default = ""
}

#####
# iam
#####

variable "instance_profile_id" {
  type = string
  default = ""
}
variable "iam_managed_policies" {
  type = list(string)
  default = []
  description = "List of managed policies to add to instance profile.  Instance profile must not be specified as it has precendance"
}

variable "json_policy" {
  type = string
  default = ""
  description = "A user supplied policy to add to the instance"
}

variable "json_policy_name" {
  type = string
  default = ""
  description = "The name of the user defined policy"
}

//#########
//# logging
//#########
//
//variable "log_config_bucket" {
//  type = string
//  default = ""
//}
//variable "log_config_key" {
//  type = string
//  default = ""
//}

