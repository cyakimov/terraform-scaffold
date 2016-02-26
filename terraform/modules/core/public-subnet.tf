resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "${var.name_prefix}public-gateway"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

// Do not embed routes as if the route-table is created with embedded routes,
// one cannot use aws_route to add routes after the fact (e.g. adding routes
// for vpc peering
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "${var.name_prefix}public-routes"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route" "public-igw" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "public-primary" {
  vpc_id            = "${aws_vpc.primary.id}"
  cidr_block        = "${var.public_primary_subnet_cidr}"
  availability_zone = "${var.aws_primary_availability_zone}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "${var.name_prefix}public-primary-subnet"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route_table_association" "public-primary" {
  subnet_id = "${aws_subnet.public-primary.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "public-secondary" {
  vpc_id            = "${aws_vpc.primary.id}"
  cidr_block        = "${var.public_secondary_subnet_cidr}"
  availability_zone = "${var.aws_secondary_availability_zone}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "${var.name_prefix}public-secondary-subnet"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

resource "aws_route_table_association" "public-secondary" {
  subnet_id = "${aws_subnet.public-secondary.id}"
  route_table_id = "${aws_route_table.public.id}"
}
