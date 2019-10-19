output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  value = join("", aws_eip.this.*.public_ip)
  depends_on = [aws_eip.this]
}

output "instance_id" {
  value = aws_instance.this.id
}
