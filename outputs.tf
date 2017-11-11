output "public ip of cm-test" {
	value = "${aws_instance.cm-test.public_ip}"
}
output "public ip(ipv6) of cm-test" {
	value = "${aws_instance.cm-test.ipv6_addresses}"
}
