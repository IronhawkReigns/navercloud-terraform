# Example Terraform Variables Configuration
# Copy this file to terraform.tfvars and customize the values
# cp terraform.tfvars.example terraform.tfvars

# General Configuration
region       = "korea"
environment  = "dev"
project_name = "ncp-terraform-guide"

# Server Configuration
server_name = "guide-server"

# Available Windows images (these are the only ones I found working):
# - SPSW0WINNTEN0016A: Windows Server 2016 (64-bit) English Edition
server_image_product_code = "SPSW0WINNTEN0016A"

# Server specs - these combinations worked during my testing:
# - SPSVRSTAND000004A: 2vCPU, 4GB RAM, HDD (this is what we got working)
server_product_code = "SPSVRSTAND000004A"

zone = "KR-1"

# Authentication
key_name = "terraform-guide-key"

# Optional settings
enable_monitoring = false
enable_protection = false
description = "Test server created by NCP Terraform Guide"

# Notes from my testing:
# - The long provisioning times (16+ minutes) seem to be NCP infrastructure issues
# - Server name must be exactly 3-15 characters or you get validation errors
# - Linux images (SPSW0LINUX000046) don't seem to exist in the region I tested
