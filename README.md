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
  version = "~> 0.2.0"

  cluster_name = "production"
  subnet_ids = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  hostname_format = "%[3]s-master%[1]d-%[2]s"
  ami = "ami-12345678"

  extra_volumes = [
    {
      size        = "100"
      type        = "gp2"
      iops        = "3000"
      device_name = "/dev/xvdi"
    },
    {
      size        = "1000"
      type        = ""     # Use AWS default.
      iops        = "0"    # Use AWS default.
      device_name = "/dev/xvdj"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | AMI that will be used for the instance | string | n/a | yes |
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| key\_name | The SSH key to use for these instances. | string | n/a | yes |
| num | How many instances should be created | string | n/a | yes |
| security\_group\_ids | Firewall IDs to use for these instances | list | n/a | yes |
| subnet\_ids | List of subnet IDs created in this network | list | n/a | yes |
| associate\_public\_ip\_address | Associate a public IP address with the instances | string | `"true"` | no |
| dcos\_instance\_os | Operating system to use. Instead of using your own AMI you could use a provided OS. | string | `"centos_7.4"` | no |
| extra\_volume\_name\_format | Printf style format for naming the extra volumes. Inputs are cluster_name and instance ID. | string | `"extra-volumes-%s-%s"` | no |
| extra\_volumes | Extra volumes for each instance | list | `<list>` | no |
| hostname\_format | Format the hostname inputs are index+1, region, cluster_name | string | `"%[3]s-instance%[1]d-%[2]s"` | no |
| iam\_instance\_profile | The instance profile to be used for these instances | string | `""` | no |
| instance\_type | Instance Type | string | `"m4.large"` | no |
| name\_prefix | Name Prefix | string | `""` | no |
| region | region | string | `""` | no |
| root\_volume\_size | Specify the root volume size | string | `"40"` | no |
| root\_volume\_type | Specify the root volume type. Masters MUST have at least gp2 | string | `"gp2"` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |
| user\_data | User data to be used on these instances (cloud-init) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | List of instance IDs |
| os\_user | The OS user to be used |
| prereq-id | Returns the ID of the prereq script (if user_data or ami are not used) |
| private\_ips | List of private ip addresses created by this module |
| public\_ips | List of public ip addresses created by this module |

