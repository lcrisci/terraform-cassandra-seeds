variable number_of_seeds { }
variable private_subnet_ids { type = "list" }
variable cassandra_seed_ips { type = "list" }
variable instance_type { }
variable ssh_public_key { }
variable vpc_id { }
variable vpc_cidr { }
variable ephemeral_disk_device { default = "/dev/xvdh" }
variable cassandra_cluster_name { }
