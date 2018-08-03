output "instances" {
  description = "List of instances IDs created by this module"
  value       = ["${aws_instance.instance.*.id}"]
}

output "public_ips" {
  description = "List of public ip addresses created by this module"
  value       = ["${aws_instance.instance.*.public_ip}"]
}

output "private_ips" {
  description = "List of private ip addresses created by this module"
  value       = ["${aws_instance.instance.*.private_ip}"]
}
