output "private_ip" {
  value =  concat(aws_instance.this.*.private_ip, [""])[0]
}

output "public_ip" {
  value = var.create_eip ? concat(aws_eip.this.*.public_ip, [""])[0] : concat(aws_instance.this.*.public_ip, [""])[0]
}

output "eip_id" {
  value = concat(aws_eip.this.*.id, [""])[0]
}

output "instance_id" {
  value =  concat(aws_instance.this.*.id, [""])[0]
}

output "volume_path" {
  value = var.volume_path
}

output "key_name" {
  value = var.key_name == "" ?  concat(aws_key_pair.this.*.key_name, [""])[0] : var.key_name
}

output "instance_profile_id" {
  value = var.instance_profile_id == "" ? concat(aws_iam_instance_profile.this.*.id, [""])[0] : var.instance_profile_id
}
