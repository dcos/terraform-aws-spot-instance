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
 *
 *   extra_volumes = [
 *     {
 *       size        = "100"
 *       type        = "gp2"
 *       iops        = "3000"
 *       device_name = "/dev/xvdi"
 *     },
 *     {
 *       size        = "1000"
 *       type        = ""     # Use AWS default.
 *       iops        = "0"    # Use AWS default.
 *       device_name = "/dev/xvdj"
 *     }
 *   ]
 * }
 *```
 */

provider "aws" {}

locals {
  # NOTE: This is to workaround the divide by zero warning from Terraform.
  num_extra_volumes = "${length(var.extra_volumes) > 0 ? length(var.extra_volumes) : 1}"

  # NOTE: This is to make "lookup" happy. Otherwise, it will complain
  # about the type cannot be derived if "var.extra_volumes" is not
  # set.
  extra_volumes = "${concat(var.extra_volumes, list(map("dummy", "dummy")))}"
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

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.region, var.cluster_name),
                                "Cluster", var.cluster_name,
                                "KubernetesCluster", var.cluster_name))}"

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

resource "aws_ebs_volume" "volume" {
  # We group volumes from one instance first. For instance:
  # - length(var.extra_volumes) = 2 (volumes)
  # - var.num = 3 (instances)
  #
  # We will get:
  # - volume.0 (instance 0)
  # - volume.1 (instance 0)
  # - volume.2 (instance 1)
  # - volume.3 (instance 1)
  # - volume.4 (instance 2)
  # - volume.5 (instance 2)
  count = "${var.num * length(var.extra_volumes)}"

  availability_zone = "${element(aws_instance.instance.*.availability_zone, count.index / local.num_extra_volumes)}"
  size              = "${lookup(local.extra_volumes[count.index % local.num_extra_volumes], "size", "120")}"
  type              = "${lookup(local.extra_volumes[count.index % local.num_extra_volumes], "type", "")}"
  iops              = "${lookup(local.extra_volumes[count.index % local.num_extra_volumes], "iops", "0")}"

  tags = "${merge(var.tags, map(
                "Name", format(var.extra_volume_name_format,
                               var.cluster_name,
                               element(aws_instance.instance.*.id, count.index / local.num_extra_volumes)),
                "Cluster", var.cluster_name))}"
}

resource "aws_volume_attachment" "volume-attachment" {
  count        = "${var.num * length(var.extra_volumes)}"
  device_name  = "${lookup(local.extra_volumes[count.index % local.num_extra_volumes], "device_name", "dummy")}"
  volume_id    = "${element(aws_ebs_volume.volume.*.id, count.index)}"
  instance_id  = "${element(aws_instance.instance.*.id, count.index / local.num_extra_volumes)}"
  force_detach = true
}

resource "null_resource" "instance-prereq" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    current_instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  }

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
