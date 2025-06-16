# Basic NCP Server Example
# Creates a simple Windows Server 2016 instance on Naver Cloud Platform
# Tested during my internship at Naver Cloud Platform

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
  # Set these environment variables:
  # export NCLOUD_ACCESS_KEY="your-access-key"
  # export NCLOUD_SECRET_KEY="your-secret-key"
  region = var.region
}

# Login Key (SSH Key Pair)
# Required for all NCP server instances
resource "ncloud_login_key" "main" {
  key_name = var.key_name
}

# Server Instance
# Tested combinations that work reliably
resource "ncloud_server" "main" {
  name = var.server_name
  
  # These combinations were tested during my internship
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.server_product_code
  
  login_key_name = ncloud_login_key.main.key_name
  zone = var.zone
}

# Data sources for checking available options
data "ncloud_server_images" "available" {
}

data "ncloud_server_products" "compatible" {
  server_image_product_code = var.server_image_product_code
}
