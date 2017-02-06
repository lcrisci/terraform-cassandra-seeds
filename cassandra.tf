#--------------------------------------------------------------
# This module creates all resources necessary for Cassandra
#--------------------------------------------------------------
data "template_file" "user_data" {
  count    = "${length(split(",", var.private_subnet_ids))}"
  template = "${file("${path.module}/cassandra.sh.tpl")}"

  vars {
    ephemeral_disk_device = "${var.ephemeral_disk_device}"
    cassandra_seed_ips = "${var.cassandra_seed_ips}"
    cassandra_cluster_name = "${var.cassandra_cluster_name}"
    private_ip = "${element(split(",", var.cassandra_seed_ips), count.index)}"
    node_index = "${count.index}"
  }
}

resource "aws_key_pair" "cassandra" {
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "cassandra" {
  count = "${length(split(",", var.private_subnet_ids))}"
  instance_type = "${var.instance_type}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.cassandra.key_name}"
  private_ip = "${element(split(",", var.cassandra_seed_ips), count.index)}"
  subnet_id = "${element(split(",", var.private_subnet_ids), count.index)}"
  user_data = "${element(data.template_file.user_data.*.rendered, count.index)}"
  vpc_security_group_ids = [
    "${module.cassandra_security_group.security_group_id}",
    "${aws_security_group.allow_internet_access.id}",
    "${aws_security_group.allow_all_ssh_access.id}"
  ]
  ephemeral_block_device {
    device_name = "${var.ephemeral_disk_device}"
    virtual_name = "ephemeral0"
  }

  tags {
    Name = "cassandra_seed_${count.index}"
  }
}
