output "instances" {
  description = "List of instance IDs"
  value       = ["${aws_spot_instance_request.instance.*.spot_instance_id}"]
}

output "public_ips" {
  description = "List of public ip addresses created by this module"
  value       = ["${aws_spot_instance_request.instance.*.public_ip}"]
}

output "private_ips" {
  description = "List of private ip addresses created by this module"
  value       = ["${aws_spot_instance_request.instance.*.private_ip}"]
}

output "os_user" {
  description = "The OS user to be used"
  value       = "${module.dcos-tested-oses.user}"
}

output "prereq-id" {
  description = "Returns the ID of the prereq script (if user_data or ami are not used)"
  value       = ""
}
