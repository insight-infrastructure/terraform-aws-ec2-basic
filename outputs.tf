output "private_ip" {
  value = var.spot_price == 0 ? aws_instance.this.*.private_ip[0] : aws_spot_instance_request.this.*.private_ip[0]
}

output "instance_id" {
  value = var.spot_price == 0 ? aws_instance.this.*.id[0] : module.instance_id.stdout
}