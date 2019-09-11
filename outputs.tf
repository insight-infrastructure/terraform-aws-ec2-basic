output "private_ip" {
  value = var.spot_price == 0 ? aws_instance.this.0.private_ip : aws_spot_instance_request.this.0.private_ip
}

output "instance_id" {
  value = var.spot_price == 0 ? aws_instance.this.0.id : module.instance_id.stdout
}
