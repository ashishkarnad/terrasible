#
# Yep. Good guess it was encoded.
#
provider "aws" {
  region = "${var.awsRegion}"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "default_gateway" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "web" {
  name = "U2FpbnNidXJ5-web"
  description = "Security Group for Web-Tier. nginx will be used as LB."
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 8484
    to_port = 8484
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8
    to_port = 0
  }

  # Should be hardened after launch
  # ... but would be over engineering at this stage.
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "U2FpbnNidXJ5-app"
  description = "Security group for App-Tier. A go executable will be running as a webserver"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 8484
    to_port = 8484
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8
    to_port = 0
  }

  # Should be hardened after launch
  # ... but would be over engineering at this stage.
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# Let there be light!
resource "aws_key_pair" "publicKey" {
  key_name = "${var.publicKeyName}"
  public_key = "${file(var.publicKeyPath)}"
}

resource "aws_instance" "web" {
  connection {
    user = "ubuntu"
  }

  count = 1
  instance_type = "t1.micro"
  ami = "${lookup(var.awsAmis, var.awsRegion)}"
  key_name = "${aws_key_pair.publicKey.id}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id = "${aws_subnet.default.id}"
  tags = {
    Role = "web"
    Env = "dev"
  }
}

resource "aws_instance" "app" {
  connection {
    user = "ubuntu"
  }

  count = 2
  instance_type = "t1.micro"
  ami = "${lookup(var.awsAmis, var.awsRegion)}"
  key_name = "${aws_key_pair.publicKey.id}"
  vpc_security_group_ids = ["${aws_security_group.app.id}"]
  subnet_id = "${aws_subnet.default.id}"
  tags = {
    Role = "app"
    Env = "dev"
  }
}


