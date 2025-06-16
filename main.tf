# Multi-Server with Security Groups Example
# Creates multiple servers with proper security group configuration
# Demonstrates production-ready security practices for NCP

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

# Login Key for server access
resource "ncloud_login_key" "main" {
  key_name = var.key_name
}

# Security Group for Web Servers
resource "ncloud_access_control_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers - HTTP/HTTPS/RDP access"
}

# Security Group for Database Servers
resource "ncloud_access_control_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database servers - restricted access"
}

# Security Group Rules for Web Servers
resource "ncloud_access_control_group_rule" "web_http" {
  access_control_group_no = ncloud_access_control_group.web.id
  
  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
    description = "HTTP access from anywhere"
  }
}

resource "ncloud_access_control_group_rule" "web_https" {
  access_control_group_no = ncloud_access_control_group.web.id
  
  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "443"
    description = "HTTPS access from anywhere"
  }
}

resource "ncloud_access_control_group_rule" "web_rdp" {
  access_control_group_no = ncloud_access_control_group.web.id
  
  inbound {
    protocol    = "TCP"
    ip_block    = var.admin_access_cidr
    port_range  = "3389"
    description = "RDP access for administrators"
  }
}

# Security Group Rules for Database Servers
resource "ncloud_access_control_group_rule" "db_mysql" {
  access_control_group_no = ncloud_access_control_group.db.id
  
  inbound {
    protocol                = "TCP"
    source_access_control_group_no = ncloud_access_control_group.web.id
    port_range             = "3306"
    description            = "MySQL access from web servers only"
  }
}

resource "ncloud_access_control_group_rule" "db_rdp" {
  access_control_group_no = ncloud_access_control_group.db.id
  
  inbound {
    protocol    = "TCP"
    ip_block    = var.admin_access_cidr
    port_range  = "3389"
    description = "RDP access for administrators"
  }
}

# Web Servers
resource "ncloud_server" "web" {
  count = var.web_server_count
  
  name = "${var.project_name}-web-${count.index + 1}"
  
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.web_server_product_code
  
  login_key_name = ncloud_login_key.main.key_name
  zone           = var.zone
  
  access_control_group_configuration_no_list = [ncloud_access_control_group.web.id]
  
  # Optional: Add description
  description = "Web server ${count.index + 1} for ${var.project_name}"
}

# Database Servers
resource "ncloud_server" "db" {
  count = var.db_server_count
  
  name = "${var.project_name}-db-${count.index + 1}"
  
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.db_server_product_code
  
  login_key_name = ncloud_login_key.main.key_name
  zone           = var.zone
  
  access_control_group_configuration_no_list = [ncloud_access_control_group.db.id]
  
  description = "Database server ${count.index + 1} for ${var.project_name}"
}

# Public IP for Load Balancer (if needed)
resource "ncloud_public_ip" "lb" {
  count = var.create_load_balancer ? 1 : 0
  
  # Note: This is a placeholder for load balancer public IP
  # Actual load balancer configuration would require additional resources
}

# Data sources for reference
data "ncloud_server_images" "available" {
}

data "ncloud_server_products" "compatible" {
  server_image_product_code = var.server_image_product_code
}

# Local values for organization
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  
  # Server categorization
  web_servers = {
    for idx, server in ncloud_server.web : idx => {
      name       = server.name
      id         = server.id
      private_ip = server.private_ip
      public_ip  = server.public_ip
      role       = "web"
    }
  }
  
  db_servers = {
    for idx, server in ncloud_server.db : idx => {
      name       = server.name
      id         = server.id
      private_ip = server.private_ip
      public_ip  = server.public_ip
      role       = "database"
    }
  }
}
