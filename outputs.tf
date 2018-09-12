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

output "os_user" {
  description = "Output the OS user if default AMI is used"
  value       = "${module.dcos-tested-oses.user}"
}

output "prereq-id" {
  description = "Returns the ID of the prereq script (if user_data or ami are not used)"
  value       = "${join(",", flatten(list(null_resource.instance-prereq.*.id)))}"
}
