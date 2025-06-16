# Input Variables for Basic NCP Server
# Configuration options tested during my NCP internship

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
  description = "Name of the project for resource tagging"
  type        = string
  default     = "ncp-terraform-guide"
}

# Server Configuration
variable "server_name" {
  description = "Name of the server instance (3-15 characters)"
  type        = string
  default     = "test-server"
  
  validation {
    condition     = length(var.server_name) >= 3 && length(var.server_name) <= 15
    error_message = "Server name must be between 3 and 15 characters (NCP requirement)."
  }
}

variable "server_image_product_code" {
  description = "Product code for server OS image"
  type        = string
  default     = "SPSW0WINNTEN0016A"  # Windows Server 2016 (64-bit) English
}

variable "server_product_code" {
  description = "Product code for server specifications (CPU, Memory, Disk)"
  type        = string
  default     = "SPSVRSTAND000004A"  # 2vCPU, 4GB RAM, Standard
  # Note: Found SSD servers provision faster during testing
}

variable "zone" {
  description = "Availability zone for server placement"
  type        = string
  default     = "KR-1"
  
  validation {
    condition     = contains(["KR-1"], var.zone)
    error_message = "Zone must be KR-1."
  }
}

# Authentication Configuration
variable "key_name" {
  description = "Name for the login key (SSH key pair)"
  type        = string
  default     = "terraform-guide-key"
}

# Optional Configuration
variable "enable_monitoring" {
  description = "Enable fee-charging monitoring for the server"
  type        = bool
  default     = false
}

variable "enable_protection" {
  description = "Enable server termination protection"
  type        = bool
  default     = false
}

variable "description" {
  description = "Description for the server instance"
  type        = string
  default     = "Server created by Terraform - NCP Guide"
}

# Server Product Options I've tested:
#
# Standard Servers:
# - SPSVRSTAND000004A: 2vCPU, 4GB RAM, HDD
# - SPSVRSTAND000005A: 4vCPU, 8GB RAM, HDD
# - SPSVRSTAND000049A: 2vCPU, 2GB RAM, HDD
#
# From my testing, provisioning times vary quite a bit
# The 16+ minute waits we experienced seem to be infrastructure issues rather than config problems
