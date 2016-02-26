resource "aws_eip" "nat_gateway_ip_primary" {
  vpc = true
}

resource "aws_eip" "nat_gateway_ip_secondary" {
  vpc = true
}

resource "aws_nat_gateway" "primary" {
  allocation_id = "${aws_eip.nat_gateway_ip_primary.id}"
  subnet_id = "${aws_subnet.public-primary.id}"
  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "secondary" {
  allocation_id = "${aws_eip.nat_gateway_ip_secondary.id}"
  subnet_id = "${aws_subnet.public-secondary.id}"
  depends_on = ["aws_internet_gateway.default"]
}

// Do not embed routes as if the route-table is created with embedded routes,
// one cannot use aws_route to add routes after the fact (e.g. adding routes
// for vpc peering)
resource "aws_route_table" "private-primary" {
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "${var.name_prefix}private-primary-routes"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route" "private-primary-igw" {
  route_table_id = "${aws_route_table.private-primary.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.primary.id}"
}

// Do not embed routes as if the route-table is created with embedded routes,
// one cannot use aws_route to add routes after the fact (e.g. adding routes
// for vpc peering)
resource "aws_route_table" "private-secondary" {
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "${var.name_prefix}private-secondary-routes"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route" "private-secondary-igw" {
  route_table_id = "${aws_route_table.private-secondary.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.secondary.id}"
}

resource "aws_subnet" "private-primary" {
  vpc_id            = "${aws_vpc.primary.id}"
  cidr_block        = "${var.private_primary_subnet_cidr}"
  availability_zone = "${var.aws_primary_availability_zone}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.name_prefix}private-primary-subnet"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_subnet" "private-secondary" {
  vpc_id            = "${aws_vpc.primary.id}"
  cidr_block        = "${var.private_secondary_subnet_cidr}"
  availability_zone = "${var.aws_secondary_availability_zone}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.name_prefix}private-secondary-subnet"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route_table_association" "private-primary" {
  subnet_id = "${aws_subnet.private-primary.id}"
  route_table_id = "${aws_route_table.private-primary.id}"
}

resource "aws_route_table_association" "private-secondary" {
  subnet_id = "${aws_subnet.private-secondary.id}"
  route_table_id = "${aws_route_table.private-secondary.id}"
}
