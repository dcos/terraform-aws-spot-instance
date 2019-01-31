/**
 * AWS Instance
 * ============
 * This is an module to creates a DC/OS AWS Instance.
 *
 * If `ami` variable is not set. This module uses the mesosphere suggested OS
 * which also includes all prerequisites.
 *
 * Using you own AMI
 * -----------------
 * If you choose to use your own AMI please make sure the DC/OS related
 * prerequisites are met. Take a look at https://docs.mesosphere.com/1.11/installing/ent/custom/system-requirements/install-docker-RHEL/
 *
 * EXAMPLE
 * -------
 *
 *```hcl
 * module "dcos-master-instance" {
 *   source  = "terraform-dcos/instance/aws"
 *   version = "~> 0.1.0"
 *
 *   cluster_name = "production"
 *   subnet_ids = ["subnet-12345678"]
 *   security_group_ids = ["sg-12345678"]
 *   hostname_format = "%[3]s-master%[1]d-%[2]s"
 *   ami = "ami-12345678"
 * }
 *```
 */

provider "aws" {}

// If name_prefix exists, merge it into the cluster_name
locals {
  cluster_name = "${var.name_prefix != "" ? "${var.cluster_name}-${var.name_prefix}" : var.cluster_name}"
}

module "dcos-tested-oses" {
  source  = "dcos-terraform/tested-oses/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  os = "${var.dcos_instance_os}"
}

resource "aws_instance" "instance" {
  instance_type = "${var.instance_type}"
  ami           = "${coalesce(var.ami, module.dcos-tested-oses.aws_ami)}"

  count                       = "${var.num}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${var.security_group_ids}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  iam_instance_profile        = "${var.iam_instance_profile}"

  # availability_zone = "${element(var.availability_zones, count.index % length(var.availability_zones)}"
  subnet_id = "${element(var.subnet_ids, count.index % length(var.subnet_ids))}"

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.region, local.cluster_name),
                                "Cluster", local.cluster_name,
                                "KubernetesCluster", local.cluster_name))}"

  root_block_device {
    volume_size           = "${var.root_volume_size}"
    volume_type           = "${var.root_volume_type}"
    delete_on_termination = true
  }

  user_data = "${var.user_data}"

  lifecycle {
    ignore_changes = ["user_data", "ami"]
  }
}

resource "null_resource" "instance-prereq" {
  // if the user supplies an AMI or user_data we expect the prerequisites are met.
  count = "${coalesce(var.ami, var.user_data) == "" ? var.num : 0}"

  connection {
    host = "${var.associate_public_ip_address ? element(aws_instance.instance.*.public_ip, count.index) : element(aws_instance.instance.*.private_ip, count.index)}"
    user = "${module.dcos-tested-oses.user}"
  }

  provisioner "file" {
    content = "${module.dcos-tested-oses.os-setup}"

    destination = "/tmp/dcos-prereqs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dcos-prereqs.sh",
      "sudo bash -x /tmp/dcos-prereqs.sh",
    ]
  }

  depends_on = ["aws_instance.instance"]
}
