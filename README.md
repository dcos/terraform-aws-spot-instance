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
  version = "~> 0.1"

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
| ami | Specify the AMI to be used. | string | - | yes |
| associate_public_ip_address | The instance profile to be used for these instances | string | `true` | no |
| cluster_name | Specify the cluster name all resources get named and tagged with | string | - | yes |
| hostname_format | Format the hostname inputs are index+1, region, cluster_name | string | `%[3]s-instance%[1]d-%[2]s` | no |
| iam_instance_profile | The instance profile to be used for these instances | string | `` | no |
| instance_type | Specify the instance type | string | `m4.large` | no |
| key_name | The SSH key to use for these instances. | string | - | yes |
| num | How many instances should be created | string | - | yes |
| region | Specify the region to be used | string | `` | no |
| root_volume_size | Specify the root volume size | string | `40` | no |
| root_volume_type | Specify the root volume type. Masters MUST have at least gp2 | string | `gp2` | no |
| security_group_ids | Firewall IDs to use for these instances | list | - | yes |
| subnet_ids | Subnets to spawn the instances in. The module tries to distribute the instances | list | - | yes |
| tags | Add special tags to the resources created by this module | map | `<map>` | no |
| user_data | The user data to be used on these instances. E.g. cloud init | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | List of instances IDs created by this module |
| private_ips | List of private ip addresses created by this module |
| public_ips | List of public ip addresses created by this module |

