#--------------------------------------------------------------
# This module creates all resources necessary for Cassandra
#--------------------------------------------------------------
data "template_file" "user_data" {
  count    = "${var.number_of_seeds}"
  template = "${file("${path.module}/cassandra.sh.tpl")}"

  vars {
    ephemeral_disk_device = "${var.ephemeral_disk_device}"
    cassandra_seed_ips = "${join(",", var.cassandra_seed_ips)}"
    cassandra_cluster_name = "${var.cassandra_cluster_name}"
    private_ip = "${element(var.cassandra_seed_ips, count.index)}"
    node_index = "${count.index}"
  }
}

resource "aws_key_pair" "cassandra" {
  public_key = "${var.ssh_public_key}"
  key_name = "cassandra_${var.cassandra_cluster_name}_ssh_key"
}

resource "aws_instance" "cassandra" {
  count = "${var.number_of_seeds}"
  instance_type = "${var.instance_type}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.cassandra.key_name}"
  private_ip = "${element(var.cassandra_seed_ips, count.index)}"
  subnet_id = "${element(var.private_subnet_ids, count.index)}"
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
    Depends_id = "${var.depends_id}"
  }
}
