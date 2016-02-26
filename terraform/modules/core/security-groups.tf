// Default security group
// This duplicates rules present in vpc default group
// aws_vpc.primary.default_security_group_id which gets created automatically
// by aws, but we can't edit from terraform, so we use the editable one below
// instead when creating an instance
resource "aws_security_group" "default" {
  name = "${var.name_prefix}default"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${aws_vpc.primary.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}default"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

/* Security group for ssh */
resource "aws_security_group" "ssh" {
  name = "${var.name_prefix}ssh"
  description = "Security group that allows ssh traffic from internet"
  vpc_id = "${aws_vpc.primary.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}ssh"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}

/* Security group for the web */
resource "aws_security_group" "web" {
  name = "${var.name_prefix}web"
  description = "Security group for web that allows web traffic from internet"
  vpc_id = "${aws_vpc.primary.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}web"
    Environment = "${var.environment}"
    Source = "terraform"
  }
}
