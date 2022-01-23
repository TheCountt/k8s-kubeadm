# declaring all avaialability zones in AWS available
data "aws_availability_zones" "available-zones" {
  state = "available"
}

# create vpc
resource "aws_vpc" "k8s-vpc" {
  cidr_block                     = var.vpc_cidr
  enable_dns_support             = var.enable_dns_support
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags = var.resource_tag
}

# create dhcp options
resource "aws_vpc_dhcp_options" "k8s-dhcp-option" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = var.resource_tag
}

# associate dhcp options
resource "aws_vpc_dhcp_options_association" "k8s-dns_resolver" {
  vpc_id          = aws_vpc.k8s-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.k8s-dhcp-option.id
}

# create subnet
resource "aws_subnet" "k8s-subnet" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = var.resource_tag
}

# create service cidr and attach to vpc
resource "aws_vpc_ipv4_cidr_block_association" "service_cidr" {
  vpc_id     = aws_vpc.k8s-vpc.id
  cidr_block = var.service_cidr
}


# create internet gateway and attach to vpc
resource "aws_internet_gateway" "k8s-ig" {
  vpc_id = aws_vpc.k8s-vpc.id
  
  tags = var.resource_tag
}


# create route table
resource "aws_route_table" "k8s-rtb" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = var.resource_tag
}

# create route for internet gateway
resource "aws_route" "k8s-internet-gateway" {
  route_table_id         = "${aws_route_table.k8s-rtb.id}"
  destination_cidr_block = var.all_ips
  gateway_id             = "${aws_internet_gateway.k8s-ig.id}"
  depends_on             = [aws_route_table.k8s-rtb]
}


# associate subnet to the route table
resource "aws_route_table_association" "k8s-association" {
  subnet_id      = aws_subnet.k8s-subnet.id
  route_table_id = aws_route_table.k8s-rtb.id
}

/////////////////////////////////////////////////////////////////////////


////////////////////////  SECURITY GROUPS ////////////////////////

resource "aws_security_group" "k8s-sg" {
  name        = "k8s-sg"
  vpc_id      = aws_vpc.k8s-vpc.id
  description = "Creating Traffic rules"

# create a dynamic block for ports 22, 6443, 80, 10250
  dynamic "ingress" {
    for_each = var.ingress
    
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [var.all_ips]
    }
  }

 # Create Inbound traffic for all communication within the subnet to connect on ports used by the master node(s)
  ingress {
    description = "master nodes"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }

   # Create Inbound traffic for all communication within the subnet to connect on ports used by the worker nodes
  ingress {
    description = "worker nodes"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }

   # Create ICMP ingress for all types
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.all_ips]
  }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ips]
  }

  tags = var.resource_tag
}












