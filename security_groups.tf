module "cassandra_security_group" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_cassandra"
  security_group_name = "security-group-cassandra"
  vpc_id = "${var.vpc_id}"
  source_cidr_block = ["${var.vpc_cidr}"]
}

resource "aws_security_group" "allow_internet_access" {
  name = "allow_internet_access"
  description = "Allow outbound internet communication."
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "cluster_internet"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_ssh_access" {
  name = "allow_all_ssh_access"
  description = "ALlow ssh access from any ip"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "cluster_ssh"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
