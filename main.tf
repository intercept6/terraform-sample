provider "aws" {
	region = "ap-northeast-1"
}

resource "aws_vpc" "myVPC" {
	cidr_block = "10.1.0.0/16"
	assign_generated_ipv6_cidr_block = "true"
	instance_tenancy = "default"
	enable_dns_support = "true"
	enable_dns_hostnames = "false"
	tags {
		Name = "myVPC"
		Project = "cm-test"
	}
}

resource "aws_internet_gateway" "myGW" {
	vpc_id = "${aws_vpc.myVPC.id}"
	tags {
		Name = "myGW"
		Project = "cm-test"
	}
}

resource "aws_subnet" "public-a" {
	vpc_id = "${aws_vpc.myVPC.id}"
	cidr_block = "10.1.1.0/24"
	ipv6_cidr_block = "${cidrsubnet(aws_vpc.myVPC.ipv6_cidr_block, 8, 1)}"
	assign_ipv6_address_on_creation = "true"
	availability_zone = "ap-northeast-1a"
	tags {
		Name = "cm-test"
		Project = "cm-test"
	}
}

resource "aws_route_table" "public-route" {
	vpc_id = "${aws_vpc.myVPC.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.myGW.id}"
	}
	route {
		ipv6_cidr_block = "::/0"
		gateway_id = "${aws_internet_gateway.myGW.id}"
	}
	tags {
		Name = "route"
		Project = "cm-test"
	}
}

resource "aws_route_table_association" "public-a" {
	subnet_id = "${aws_subnet.public-a.id}"
	route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_security_group" "admin" {
	name = "admin"
	description = "Allow SSH inbound traffice"
	vpc_id = "${aws_vpc.myVPC.id}"
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		ipv6_cidr_blocks = ["2409:13:a0c0:1b00::/56"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
	tags {
		Project = "cm-test"
	}
}

resource "aws_instance" "cm-test" {
	ami = "${var.images["ap-northeast-1"]}"
	instance_type = "t2.micro"
	key_name = "arata001"
	vpc_security_group_ids = [
		"${aws_security_group.admin.id}"
	]
	subnet_id = "${aws_subnet.public-a.id}"
	associate_public_ip_address = "true"
	ipv6_address_count = "1"
	root_block_device = {
		volume_type = "gp2"
		volume_size = "8"
	}
	tags {
		Name = "cm-test"
		Project = "cm-test"
	}
}
