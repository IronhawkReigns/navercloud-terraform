# Output Values for Basic NCP Server
# Key information about the created resources

# Server Information
output "server_id" {
  description = "Unique ID of the created server"
  value       = ncloud_server.main.id
}

output "server_instance_no" {
  description = "Instance number of the server"
  value       = ncloud_server.main.instance_no
}

output "server_name" {
  description = "Name of the created server"
  value       = ncloud_server.main.name
}

# =============================================================================
# Network Information
# =============================================================================
output "public_ip" {
  description = "Public IP address of the server (if assigned)"
  value       = ncloud_server.main.public_ip
}

output "private_ip" {
  description = "Private IP address of the server"
  value       = ncloud_server.main.private_ip
}

output "port_forwarding_public_ip" {
  description = "Public IP for port forwarding (if configured)"
  value       = ncloud_server.main.port_forwarding_public_ip
}

output "port_forwarding_external_port" {
  description = "External port for port forwarding (if configured)"
  value       = ncloud_server.main.port_forwarding_external_port
}

output "port_forwarding_internal_port" {
  description = "Internal port for port forwarding (if configured)"
  value       = ncloud_server.main.port_forwarding_internal_port
}

# =============================================================================
# Server Specifications
# =============================================================================
output "server_image_name" {
  description = "Name of the server image used"
  value       = ncloud_server.main.server_image_name
}

output "server_image_product_code" {
  description = "Product code of the server image"
  value       = ncloud_server.main.server_image_product_code
}

output "server_product_code" {
  description = "Product code of the server specifications"
  value       = ncloud_server.main.server_product_code
}

output "cpu_count" {
  description = "Number of CPU cores allocated to the server"
  value       = ncloud_server.main.cpu_count
}

output "memory_size" {
  description = "Amount of memory allocated to the server"
  value       = ncloud_server.main.memory_size
}

output "base_block_storage_size" {
  description = "Size of the base block storage"
  value       = ncloud_server.main.base_block_storage_size
}

output "platform_type" {
  description = "Platform type of the server (LNX64 or WND64)"
  value       = ncloud_server.main.platform_type
}

# =============================================================================
# Authentication Information
# =============================================================================
output "login_key_name" {
  description = "Name of the login key used for server access"
  value       = ncloud_server.main.login_key_name
}

output "zone" {
  description = "Availability zone where the server is deployed"
  value       = ncloud_server.main.zone
}

output "region" {
  description = "Region where the server is deployed"
  value       = ncloud_server.main.region
}

# =============================================================================
# Detailed Server Information (for troubleshooting)
# =============================================================================
output "server_spec_code" {
  description = "Specification code of the server"
  value       = ncloud_server.main.server_spec_code
}

output "hypervisor_type" {
  description = "Type of hypervisor used"
  value       = ncloud_server.main.hypervisor_type
}

output "is_fee_charging_monitoring" {
  description = "Whether fee-charging monitoring is enabled"
  value       = ncloud_server.main.is_fee_charging_monitoring
}

output "is_protect_server_termination" {
  description = "Whether server termination protection is enabled"
  value       = ncloud_server.main.is_protect_server_termination
}

# =============================================================================
# Connection Information
# =============================================================================
output "connection_info" {
  description = "Information for connecting to the server"
  value = {
    public_ip    = ncloud_server.main.public_ip
    private_ip   = ncloud_server.main.private_ip
    platform     = ncloud_server.main.platform_type
    login_key    = ncloud_server.main.login_key_name
    zone         = ncloud_server.main.zone
    
    # Connection instructions based on platform
    connection_method = ncloud_server.main.platform_type == "WND64" ? "RDP (Remote Desktop)" : "SSH"
    default_port     = ncloud_server.main.platform_type == "WND64" ? 3389 : 22
  }
}

# =============================================================================
# Resource Summary
# =============================================================================
output "resource_summary" {
  description = "Summary of created resources"
  value = {
    server = {
      name         = ncloud_server.main.name
      id           = ncloud_server.main.id
      instance_no  = ncloud_server.main.instance_no
      public_ip    = ncloud_server.main.public_ip
      private_ip   = ncloud_server.main.private_ip
      cpu_count    = ncloud_server.main.cpu_count
      memory_size  = ncloud_server.main.memory_size
      platform     = ncloud_server.main.platform_type
      zone         = ncloud_server.main.zone
    }
    login_key = {
      name = ncloud_login_key.main.key_name
    }
  }
}

# =============================================================================
# Available Options (for reference)
# =============================================================================
output "available_server_images" {
  description = "List of available server images in this region"
  value = {
    for image in data.ncloud_server_images.available.server_images :
    image.product_code => {
      name           = image.product_name
      type           = image.product_type
      os_information = try(image.os_information, "N/A")
    }
  }
}

output "compatible_server_products" {
  description = "List of server products compatible with the chosen image"
  value = {
    for product in data.ncloud_server_products.compatible.server_products :
    product.product_code => {
      name        = product.product_name
      cpu_count   = product.cpu_count
      memory_size = product.memory_size
    }
  }
}
