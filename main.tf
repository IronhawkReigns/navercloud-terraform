# Complete VPC Infrastructure with Security Groups
# Creates a full VPC environment with proper network segmentation and security
# Production-ready configuration with web and database tiers

terraform {
  required_version = ">= 1.0"
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "~> 3.0"
    }
  }
}

# Provider Configuration
provider "ncloud" {
  region = var.region
}

# VPC (Virtual Private Cloud)
resource "ncloud_vpc" "main" {
  name            = "${var.project_name}-vpc"
  ipv4_cidr_block = var.vpc_cidr
}

# Internet Gateway for VPC
resource "ncloud_internet_gateway" "main" {
  vpc_no = ncloud_vpc.main.id
}

# Public Subnet for Web Servers
resource "ncloud_subnet" "public" {
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.public_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  name           = "${var.project_name}-public-subnet"
  usage_type     = "GEN"  # General purpose subnet
}

# Private Subnet for Database Servers
resource "ncloud_subnet" "private" {
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.private_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  name           = "${var.project_name}-private-subnet"
  usage_type     = "GEN"  # General purpose subnet
}

# Route Table for Public Subnet
resource "ncloud_route_table" "public" {
  vpc_no                = ncloud_vpc.main.id
  name                  = "${var.project_name}-public-rt"
  supported_subnet_type = "PUBLIC"
}

# Route for Internet Access via Internet Gateway
resource "ncloud_route" "public_internet" {
  route_table_no         = ncloud_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  target_type           = "NATGW"  # For public internet access
  target_name           = ncloud_nat_gateway.main.name
  target_no             = ncloud_nat_gateway.main.id
}

# NAT Gateway for Private Subnet Internet Access
resource "ncloud_nat_gateway" "main" {
  vpc_no    = ncloud_vpc.main.id
  subnet_no = ncloud_subnet.public.id
  zone      = var.zone
  name      = "${var.project_name}-nat-gw"
}

# Route Table for Private Subnet
resource "ncloud_route_table" "private" {
  vpc_no                = ncloud_vpc.main.id
  name                  = "${var.project_name}-private-rt"
  supported_subnet_type = "PRIVATE"
}

# Route for Private Subnet to Internet via NAT Gateway
resource "ncloud_route" "private_internet" {
  route_table_no         = ncloud_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  target_type           = "NATGW"
  target_name           = ncloud_nat_gateway.main.name
  target_no             = ncloud_nat_gateway.main.id
}

# Associate Route Tables with Subnets
resource "ncloud_route_table_association" "public" {
  route_table_no = ncloud_route_table.public.id
  subnet_no      = ncloud_subnet.public.id
}

resource "ncloud_route_table_association" "private" {
  route_table_no = ncloud_route_table.private.id
  subnet_no      = ncloud_subnet.private.id
}

# Login Key for server access
resource "ncloud_login_key" "main" {
  key_name = var.key_name
}

# Security Group for Web Servers (Public Subnet)
resource "ncloud_access_control_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers - HTTP/HTTPS/RDP access"
  vpc_no      = ncloud_vpc.main.id
}

# Security Group for Database Servers (Private Subnet)
resource "ncloud_access_control_group" "database" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database servers - restricted access"
  vpc_no      = ncloud_vpc.main.id
}

# Security Group for Bastion Host
resource "ncloud_access_control_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host - SSH/RDP access"
  vpc_no      = ncloud_vpc.main.id
}

# Web Server Security Group Rules
resource "ncloud_access_control_group_rule" "web_http" {
  access_control_group_no = ncloud_access_control_group.web.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
    description = "HTTP access from internet"
  }
}

resource "ncloud_access_control_group_rule" "web_https" {
  access_control_group_no = ncloud_access_control_group.web.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "443"
    description = "HTTPS access from internet"
  }
}

resource "ncloud_access_control_group_rule" "web_rdp_from_bastion" {
  access_control_group_no = ncloud_access_control_group.web.id

  inbound {
    protocol                       = "TCP"
    source_access_control_group_no = ncloud_access_control_group.bastion.id
    port_range                     = "3389"
    description                    = "RDP access from bastion host"
  }
}

resource "ncloud_access_control_group_rule" "web_rdp_admin" {
  access_control_group_no = ncloud_access_control_group.web.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.admin_access_cidr
    port_range  = "3389"
    description = "RDP access for administrators"
  }
}

# Database Server Security Group Rules
resource "ncloud_access_control_group_rule" "db_mysql_from_web" {
  access_control_group_no = ncloud_access_control_group.database.id

  inbound {
    protocol                       = "TCP"
    source_access_control_group_no = ncloud_access_control_group.web.id
    port_range                     = "3306"
    description                    = "MySQL access from web servers"
  }
}

resource "ncloud_access_control_group_rule" "db_sqlserver_from_web" {
  access_control_group_no = ncloud_access_control_group.database.id

  inbound {
    protocol                       = "TCP"
    source_access_control_group_no = ncloud_access_control_group.web.id
    port_range                     = "1433"
    description                    = "SQL Server access from web servers"
  }
}

resource "ncloud_access_control_group_rule" "db_rdp_from_bastion" {
  access_control_group_no = ncloud_access_control_group.database.id

  inbound {
    protocol                       = "TCP"
    source_access_control_group_no = ncloud_access_control_group.bastion.id
    port_range                     = "3389"
    description                    = "RDP access from bastion host"
  }
}

# Bastion Host Security Group Rules
resource "ncloud_access_control_group_rule" "bastion_rdp" {
  access_control_group_no = ncloud_access_control_group.bastion.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.admin_access_cidr
    port_range  = "3389"
    description = "RDP access for administrators"
  }
}

resource "ncloud_access_control_group_rule" "bastion_ssh" {
  access_control_group_no = ncloud_access_control_group.bastion.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.admin_access_cidr
    port_range  = "22"
    description = "SSH access for administrators"
  }
}

# Bastion Host (for secure access to private resources)
resource "ncloud_server" "bastion" {
  count = var.create_bastion ? 1 : 0

  name      = "${var.project_name}-bastion"
  subnet_no = ncloud_subnet.public.id

  server_image_product_code = var.server_image_product_code
  server_product_code       = var.bastion_server_product_code

  login_key_name = ncloud_login_key.main.key_name

  access_control_group_configuration_no_list = [ncloud_access_control_group.bastion.id]

  description = "Bastion host for secure access to private resources"
}

# Web Servers in Public Subnet
resource "ncloud_server" "web" {
  count = var.web_server_count

  name      = "${var.project_name}-web-${count.index + 1}"
  subnet_no = ncloud_subnet.public.id

  server_image_product_code = var.server_image_product_code
  server_product_code       = var.web_server_product_code

  login_key_name = ncloud_login_key.main.key_name

  access_control_group_configuration_no_list = [ncloud_access_control_group.web.id]

  description = "Web server ${count.index + 1} for ${var.project_name}"
}

# Database Servers in Private Subnet
resource "ncloud_server" "database" {
  count = var.db_server_count

  name      = "${var.project_name}-db-${count.index + 1}"
  subnet_no = ncloud_subnet.private.id

  server_image_product_code = var.server_image_product_code
  server_product_code       = var.db_server_product_code

  login_key_name = ncloud_login_key.main.key_name

  access_control_group_configuration_no_list = [ncloud_access_control_group.database.id]

  description = "Database server ${count.index + 1} for ${var.project_name}"
}

# Public IPs for Web Servers
resource "ncloud_public_ip" "web" {
  count = var.web_server_count

  server_instance_no = ncloud_server.web[count.index].instance_no
  description        = "Public IP for ${ncloud_server.web[count.index].name}"
}

# Public IP for Bastion Host
resource "ncloud_public_ip" "bastion" {
  count = var.create_bastion ? 1 : 0

  server_instance_no = ncloud_server.bastion[0].instance_no
  description        = "Public IP for bastion host"
}
