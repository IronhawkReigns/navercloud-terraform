# Example Configuration for Multi-Server with Security Groups
# Copy this file to terraform.tfvars and customize the values
# cp terraform.tfvars.example terraform.tfvars

# General Configuration
region       = "korea"
environment  = "dev"
project_name = "webapp"  # Keep short for server naming

# Server Configuration
server_image_product_code = "SPSW0WINNTEN0016A"  # Windows Server 2016

# Server Specifications
web_server_product_code = "SPSVRSTAND000004A"  # 2vCPU, 4GB RAM for web servers
db_server_product_code  = "SPSVRSTAND000005A"  # 4vCPU, 8GB RAM for database

zone = "KR-1"

# Multi-Server Setup
web_server_count = 2  # Number of web servers
db_server_count  = 1  # Number of database servers

# Security Configuration
# IMPORTANT: Change this to your office/home IP for better security
# Example: "203.248.252.0/24" for your office network
admin_access_cidr = "0.0.0.0/0"  # CHANGE THIS for production!

# Load Balancer
create_load_balancer = false  # Set to true if you need a load balancer IP

# Authentication
key_name = "webapp-servers-key"

# Optional Features
enable_monitoring = false
enable_protection = false

# Environment Examples:
# 
# Development Environment (minimal cost):
# web_server_count = 1
# db_server_count = 1
# web_server_product_code = "SPSVRSTAND000049A"  # 2vCPU, 2GB
# db_server_product_code = "SPSVRSTAND000004A"   # 2vCPU, 4GB
#
# Staging Environment (moderate resources):
# web_server_count = 2
# db_server_count = 1
# web_server_product_code = "SPSVRSTAND000004A"  # 2vCPU, 4GB
# db_server_product_code = "SPSVRSTAND000005A"   # 4vCPU, 8GB
#
# Production Environment (higher resources):
# web_server_count = 3
# db_server_count = 2
# web_server_product_code = "SPSVRSTAND000005A"  # 4vCPU, 8GB
# db_server_product_code = "SPSVRSTAND000006A"   # 8vCPU, 16GB
# enable_monitoring = true
# enable_protection = true

# Security Notes:
# - Web servers allow HTTP(80), HTTPS(443), and RDP(3389) from admin IPs
# - DB servers only allow MySQL(3306) from web servers and RDP from admin IPs
# - For production, set admin_access_cidr to your specific IP range
# - Consider using a bastion host for even better security

# Cost Estimation (monthly, approximate):
# Development setup (1 web + 1 db): ~$70-80/month
# Staging setup (2 web + 1 db): ~$115-125/month
# Production setup (3 web + 2 db): ~$195-215/month
