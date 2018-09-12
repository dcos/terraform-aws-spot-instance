variable "region" {
  description = "Specify the region to be used"
  default     = ""
}

variable "cluster_name" {
  description = "Specify the cluster name all resources get named and tagged with"
}

# variable "availability_zones" {
#  description = "Specify the availability zones to be used"
#  type = "list"
# }

variable "tags" {
  description = "Add special tags to the resources created by this module"
  type        = "map"
  default     = {}
}

variable "ami" {
  description = "Specify the AMI to be used."
}

variable "num" {
  description = "How many instances should be created"
}

variable "instance_type" {
  description = "Specify the instance type"
  default     = "m4.large"
}

variable "root_volume_size" {
  description = "Specify the root volume size"
  default     = "40"
}

variable "root_volume_type" {
  description = "Specify the root volume type. Masters MUST have at least gp2"
  default     = "gp2"
}

variable "subnet_ids" {
  description = "Subnets to spawn the instances in. The module tries to distribute the instances"
  type        = "list"
}

variable "security_group_ids" {
  description = "Firewall IDs to use for these instances"
  type        = "list"
}

variable "iam_instance_profile" {
  description = "The instance profile to be used for these instances"
  default     = ""
}

variable "associate_public_ip_address" {
  description = "The instance profile to be used for these instances"
  default     = true
}

variable "user_data" {
  description = "The user data to be used on these instances. E.g. cloud init"
  default     = ""
}

variable "dcos_instance_os" {
  description = "Operating system to use. Instead of using your own AMI you could use a provided OS."
  default     = "centos_7.4"
}

// TODO: Maybe use a list instead and provision keys through cloudinit
variable "key_name" {
  description = "The SSH key to use for these instances."
}

variable "hostname_format" {
  description = "Format the hostname inputs are index+1, region, cluster_name"
  default     = "%[3]s-instance%[1]d-%[2]s"
}
