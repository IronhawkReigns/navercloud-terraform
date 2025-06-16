# Complete VPC Infrastructure Configuration
# Copy this file to terraform.tfvars and customize for your environment
# cp terraform.tfvars.example terraform.tfvars

# General Configuration
region       = "korea"
environment  = "dev"
project_name = "myapp"  # Keep to 8 characters or less for server naming

# Network Configuration
vpc_cidr            = "10.0.0.0/16"    # Main VPC network range
public_subnet_cidr  = "10.0.1.0/24"    # Public subnet for web servers, bastion
private_subnet_cidr = "10.0.2.0/24"    # Private subnet for database servers
zone                = "KR-1"

# Server Configuration
server_image_product_code = "SPSW0WINNTEN0016A"  # Windows Server 2016

# Server Specifications (tested combinations)
web_server_product_code     = "SPSVRSTAND000004A"  # 2vCPU, 4GB RAM - web servers
db_server_product_code      = "SPSVRSTAND000005A"  # 4vCPU, 8GB RAM - database servers
bastion_server_product_code = "SPSVRSTAND000049A"  # 2vCPU, 2GB RAM - bastion host

# Multi-Server Configuration
web_server_count = 2        # Number of web servers in public subnet
db_server_count  = 1        # Number of database servers in private subnet
create_bastion   = true     # Create bastion host for secure access

# Security Configuration
# CRITICAL: Change this to your office/home IP for production security
# Example: "203.248.252.0/24" for your office network
admin_access_cidr = "0.0.0.0/0"  # CHANGE THIS FOR PRODUCTION

# Authentication
key_name = "vpc-infrastructure-key"

# Optional Features
enable_monitoring = false   # Set to true for production monitoring
enable_protection = false   # Set to true to prevent accidental deletion

# Environment-Specific Configurations:

# Development Environment (minimal cost):
# web_server_count = 1
# db_server_count = 1
# web_server_product_code = "SPSVRSTAND000049A"      # 2vCPU, 2GB
# db_server_product_code = "SPSVRSTAND000004A"       # 2vCPU, 4GB
# create_bastion = false
# Estimated cost: ~$80-90/month

# Staging Environment (moderate resources):
# web_server_count = 2
# db_server_count = 1
# web_server_product_code = "SPSVRSTAND000004A"      # 2vCPU, 4GB
# db_server_product_code = "SPSVRSTAND000005A"       # 4vCPU, 8GB
# create_bastion = true
# Estimated cost: ~$140-160/month

# Production Environment (high availability):
# web_server_count = 3
# db_server_count = 2
# web_server_product_code = "SPSVRSTAND000005A"      # 4vCPU, 8GB
# db_server_product_code = "SPSVRSTAND000006A"       # 8vCPU, 16GB
# create_bastion = true
# enable_monitoring = true
# enable_protection = true
# admin_access_cidr = "YOUR.OFFICE.IP.0/24"
# Estimated cost: ~$280-320/month

# Network Architecture Notes:
# 
# This configuration creates a production-ready 3-tier architecture:
#
# Internet
#     ↓
# Public Subnet (10.0.1.0/24)
# ├── Internet Gateway (for inbound traffic)
# ├── NAT Gateway (for outbound traffic from private subnet)
# ├── Web Servers [2] (public access, load balanced)
# └── Bastion Host (secure admin access)
#     ↓
# Private Subnet (10.0.2.0/24)
# └── Database Servers [1] (isolated, no direct internet access)

# Security Group Rules:
# - Web Servers: HTTP(80), HTTPS(443) from internet; RDP(3389) from admin/bastion
# - Database: MySQL(3306), SQL Server(1433) from web servers only; RDP from bastion
# - Bastion: RDP(3389), SSH(22) from admin IPs only

# Estimated Monthly Costs (approximate):
# - Web Servers (2x 2vCPU, 4GB): ~$70/month
# - Database Server (1x 4vCPU, 8GB): ~$45/month
# - Bastion Host (1x 2vCPU, 2GB): ~$25/month
# - NAT Gateway: ~$15/month
# - Public IPs (3x): ~$9/month
# - Total: ~$164/month for staging environment

# Cost Optimization Tips:
# - Use smaller instances for development
# - Consider scheduled start/stop for non-production
# - Monitor NAT Gateway data transfer costs
# - Review public IP usage regularly

# Security Best Practices:
# 1. Always set admin_access_cidr to specific IP ranges
# 2. Use bastion host for accessing private resources
# 3. Enable monitoring and logging for production
# 4. Regularly review and update security group rules
# 5. Implement backup strategies for databases
# 6. Use SSL/TLS certificates for web traffic
