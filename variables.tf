# Input Variables for Complete VPC Infrastructure
# Comprehensive configuration for production-ready VPC environment

# General Configuration
variable "region" {
  description = "NCP region for resource deployment"
  type        = string
  default     = "korea"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "myapp"
  
  validation {
    condition     = length(var.project_name) <= 8
    error_message = "Project name must be 8 characters or less for server naming."
  }
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "Public subnet CIDR must be a valid CIDR block."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
  
  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "Private subnet CIDR must be a valid CIDR block."
  }
}

variable "zone" {
  description = "Availability zone for resource placement"
  type        = string
  default     = "KR-1"
}

# Server Configuration
variable "server_image_product_code" {
  description = "Product code for server OS image"
  type        = string
  default     = "SPSW0WINNTEN0016A"  # Windows Server 2016 (64-bit) English
}

variable "web_server_product_code" {
  description = "Product code for web server specifications"
  type        = string
  default     = "SPSVRSTAND000004A"  # 2vCPU, 4GB RAM
}

variable "db_server_product_code" {
  description = "Product code for database server specifications"
  type        = string
  default     = "SPSVRSTAND000005A"  # 4vCPU, 8GB RAM
}

variable "bastion_server_product_code" {
  description = "Product code for bastion host specifications"
  type        = string
  default     = "SPSVRSTAND000049A"  # 2vCPU, 2GB RAM (minimal for bastion)
}

# Multi-Server Configuration
variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.web_server_count >= 1 && var.web_server_count <= 5
    error_message = "Web server count must be between 1 and 5."
  }
}

variable "db_server_count" {
  description = "Number of database servers to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.db_server_count >= 1 && var.db_server_count <= 3
    error_message = "Database server count must be between 1 and 3."
  }
}

variable "create_bastion" {
  description = "Whether to create a bastion host for secure access"
  type        = bool
  default     = true
}

# Security Configuration
variable "admin_access_cidr" {
  description = "CIDR block for administrative access (RDP/SSH)"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your office IP for better security
  
  validation {
    condition     = can(cidrhost(var.admin_access_cidr, 0))
    error_message = "Admin access CIDR must be a valid CIDR block."
  }
}

# Authentication Configuration
variable "key_name" {
  description = "Name for the login key (SSH key pair)"
  type        = string
  default     = "vpc-infrastructure-key"
}

# Advanced Configuration
variable "enable_monitoring" {
  description = "Enable fee-charging monitoring for servers"
  type        = bool
  default     = false
}

variable "enable_protection" {
  description = "Enable server termination protection"
  type        = bool
  default     = false
}

# Network Architecture Reference:
#
# VPC (10.0.0.0/16)
# ├── Public Subnet (10.0.1.0/24)
# │   ├── Internet Gateway
# │   ├── NAT Gateway
# │   ├── Web Servers (2vCPU, 4GB)
# │   └── Bastion Host (2vCPU, 2GB)
# └── Private Subnet (10.0.2.0/24)
#     └── Database Servers (4vCPU, 8GB)
#
# Security Groups:
# - Web SG: HTTP(80), HTTPS(443), RDP(3389) from admin/bastion
# - DB SG: MySQL(3306), SQL Server(1433) from web SG, RDP from bastion
# - Bastion SG: RDP(3389), SSH(22) from admin IPs only
#
# Routing:
# - Public Subnet: Direct internet access via Internet Gateway
# - Private Subnet: Internet access via NAT Gateway in public subnet
#
# Server Product Options (tested):
# - Bastion: SPSVRSTAND000049A (2vCPU, 2GB RAM) - minimal cost
# - Web: SPSVRSTAND000004A (2vCPU, 4GB RAM) - adequate for web servers
# - Database: SPSVRSTAND000005A (4vCPU, 8GB RAM) - better for databases
# - High-performance: SPSVRSTAND000006A (8vCPU, 16GB RAM) - for heavy workloads
