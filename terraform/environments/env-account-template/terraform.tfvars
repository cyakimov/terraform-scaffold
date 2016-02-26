environment = "dev"
name_prefix = "acme-dev-"
domain = "dev.acme.com"
internal_domain = "int.dev.acme.com"
aws_keypair_name = "acme-dev-main"
aws_keypair_path = "~/.ssh/acme-dev-main.pem"
aws_primary_availability_zone = "us-east-1a"
aws_secondary_availability_zone = "us-east-1b"
vpc_tenancy = "default"
vpc_cidr = "10.10.0.0/16"
public_primary_subnet_cidr = "10.10.0.0/24"
private_primary_subnet_cidr = "10.10.1.0/24"
public_secondary_subnet_cidr = "10.10.10.0/24"
private_secondary_subnet_cidr = "10.10.11.0/24"
vpn_client_cidr = "192.168.255.0/24"
cdn_endpoint = "cdn.dev.acme.com.s3.amazonaws.com"

ssl_cert = <<EOF
EOF

ssl_chain = <<EOF
EOF

internal_ssl_cert = <<EOF
EOF

internal_ssl_chain = <<EOF
EOF
