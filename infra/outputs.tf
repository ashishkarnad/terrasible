output "web.ip.0.public" {
  value = "${aws_instance.web.public_ip}"
}

output "web.ip.0.private" {
  value = "${aws_instance.web.private_ip}"
}

output "app.ip.0.public" {
  value = "${aws_instance.app.0.public_ip}"
}

output "app.ip.0.private" {
  value = "${aws_instance.app.0.private_ip}"
}

output "app.ip.1.public" {
  value = "${aws_instance.app.1.public_ip}"
}

output "app.ip.1.private" {
  value = "${aws_instance.app.1.private_ip}"
}