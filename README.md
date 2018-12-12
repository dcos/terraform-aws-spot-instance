AWS Instance
============
This is an module to creates a DC/OS AWS Instance.

If `ami` variable is not set. This module uses the mesosphere suggested OS
which also includes all prerequisites.

Using you own AMI
-----------------
If you choose to use your own AMI please make sure the DC/OS related
prerequisites are met. Take a look at https://docs.mesosphere.com/1.11/installing/ent/custom/system-requirements/install-docker-RHEL/

EXAMPLE
-------

```hcl
module "dcos-master-instance" {
  source  = "terraform-dcos/instance/aws"
  version = "~> 0.1.0"

  cluster_name = "production"
  subnet_ids = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  hostname_format = "%[3]s-master%[1]d-%[2]s"
  ami = "ami-12345678"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | AMI that will be used for the instance | string | - | yes |
| associate_public_ip_address | Associate a public IP address with the instances | string | `true` | no |
| cluster_name | Name of the DC/OS cluster | string | - | yes |
| dcos_instance_os | Operating system to use. Instead of using your own AMI you could use a provided OS. | string | `centos_7.4` | no |
| hostname_format | Format the hostname inputs are index+1, region, cluster_name | string | `%[3]s-instance%[1]d-%[2]s` | no |
| iam_instance_profile | The instance profile to be used for these instances | string | `` | no |
| instance_type | Instance Type | string | `m4.large` | no |
| key_name | The SSH key to use for these instances. | string | - | yes |
| num | How many instances should be created | string | - | yes |
| region | region | string | `` | no |
| root_volume_size | Specify the root volume size | string | `40` | no |
| root_volume_type | Specify the root volume type. Masters MUST have at least gp2 | string | `gp2` | no |
| security_group_ids | Firewall IDs to use for these instances | list | - | yes |
| subnet_ids | List of subnet IDs created in this network | list | - | yes |
| tags | Add custom tags to all resources | map | `<map>` | no |
| user_data | User data to be used on these instances (cloud-init) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | List of instance IDs |
| os_user | The OS user to be used |
| prereq-id | Returns the ID of the prereq script (if user_data or ami are not used) |
| private_ips | List of private ip addresses created by this module |
| public_ips | List of public ip addresses created by this module |

