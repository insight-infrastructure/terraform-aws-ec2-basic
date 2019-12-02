output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  value = var.create_eip ? join("", aws_eip.this.*.public_ip) : aws_instance.this.public_ip
//  depends_on = [aws_eip.this]
}

output "instance_id" {
  value = aws_instance.this.id
}

output "volume_path" {
  value = var.volume_path
}

output "key_name" {
  value = var.key_name == "" ? aws_key_pair.this[0].key_name : var.key_name
}

output "instance_profile_id" {
  value = var.instance_profile_id == "" ? aws_iam_instance_profile.this[0].id :var.instance_profile_id
}
