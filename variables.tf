# Input Variables for Multi-Server with Security Groups
# Extended configuration for production-like environments

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
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "ncp-multi-server"
  
  validation {
    condition     = length(var.project_name) <= 10
    error_message = "Project name must be 10 characters or less for server naming."
  }
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
  default     = "SPSVRSTAND000004A"  # 2vCPU, 4GB RAM - suitable for web servers
}

variable "db_server_product_code" {
  description = "Product code for database server specifications"
  type        = string
  default     = "SPSVRSTAND000005A"  # 4vCPU, 8GB RAM - better for databases
}

variable "zone" {
  description = "Availability zone for server placement"
  type        = string
  default     = "KR-1"
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

# Security Configuration
variable "admin_access_cidr" {
  description = "CIDR block for administrative access (RDP)"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your office IP for better security
  
  validation {
    condition     = can(cidrhost(var.admin_access_cidr, 0))
    error_message = "Admin access CIDR must be a valid CIDR block."
  }
}

variable "create_load_balancer" {
  description = "Whether to create a load balancer public IP"
  type        = bool
  default     = false
}

# Authentication Configuration
variable "key_name" {
  description = "Name for the login key (SSH key pair)"
  type        = string
  default     = "multi-server-key"
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

# Server Product Reference:
# Tested combinations for different workloads:
#
# Web Servers (moderate CPU, adequate RAM):
# - SPSVRSTAND000004A: 2vCPU, 4GB RAM, HDD
# - SPSVRSTAND000005A: 4vCPU, 8GB RAM, HDD
#
# Database Servers (higher specs for better performance):
# - SPSVRSTAND000005A: 4vCPU, 8GB RAM, HDD
# - SPSVRSTAND000006A: 8vCPU, 16GB RAM, HDD
#
# Small/Dev Environment:
# - SPSVRSTAND000049A: 2vCPU, 2GB RAM, HDD (minimal cost)
#
# Security Group Notes:
# - Web servers: Allow HTTP(80), HTTPS(443), RDP(3389) from admin IPs
# - DB servers: Allow MySQL(3306) from web servers only, RDP from admin IPs
# - Adjust admin_access_cidr to your specific IP range for better security
