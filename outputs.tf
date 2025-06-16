# Output Values for Multi-Server with Security Groups
# Comprehensive information about the created infrastructure

# Security Group Information
output "security_groups" {
  description = "Information about created security groups"
  value = {
    web = {
      id          = ncloud_access_control_group.web.id
      name        = ncloud_access_control_group.web.name
      description = ncloud_access_control_group.web.description
    }
    db = {
      id          = ncloud_access_control_group.db.id
      name        = ncloud_access_control_group.db.name
      description = ncloud_access_control_group.db.description
    }
  }
}

# Web Servers Information
output "web_servers" {
  description = "Detailed information about web servers"
  value = {
    for idx, server in ncloud_server.web : "web-${idx + 1}" => {
      id           = server.id
      instance_no  = server.instance_no
      name         = server.name
      public_ip    = server.public_ip
      private_ip   = server.private_ip
      cpu_count    = server.cpu_count
      memory_size  = server.memory_size
      zone         = server.zone
      platform     = server.platform_type
      security_group = ncloud_access_control_group.web.name
    }
  }
}

# Database Servers Information
output "db_servers" {
  description = "Detailed information about database servers"
  value = {
    for idx, server in ncloud_server.db : "db-${idx + 1}" => {
      id           = server.id
      instance_no  = server.instance_no
      name         = server.name
      public_ip    = server.public_ip
      private_ip   = server.private_ip
      cpu_count    = server.cpu_count
      memory_size  = server.memory_size
      zone         = server.zone
      platform     = server.platform_type
      security_group = ncloud_access_control_group.db.name
    }
  }
}

# Connection Information
output "connection_info" {
  description = "Connection information for all servers"
  value = {
    web_servers = {
      for idx, server in ncloud_server.web : "web-${idx + 1}" => {
        public_ip         = server.public_ip
        private_ip        = server.private_ip
        rdp_port          = 3389
        http_port         = 80
        https_port        = 443
        connection_method = "RDP (Remote Desktop)"
        login_key         = server.login_key_name
      }
    }
    db_servers = {
      for idx, server in ncloud_server.db : "db-${idx + 1}" => {
        public_ip         = server.public_ip
        private_ip        = server.private_ip
        rdp_port          = 3389
        mysql_port        = 3306
        connection_method = "RDP (Remote Desktop)"
        login_key         = server.login_key_name
        access_note       = "MySQL access restricted to web servers only"
      }
    }
  }
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "High-level summary of the created infrastructure"
  value = {
    total_servers = var.web_server_count + var.db_server_count
    web_servers   = var.web_server_count
    db_servers    = var.db_server_count
    security_groups = 2
    project_name  = var.project_name
    environment   = var.environment
    zone          = var.zone
    
    cost_estimate = {
      monthly_web_servers = "~$${var.web_server_count * 35}/month (estimated)"
      monthly_db_servers  = "~$${var.db_server_count * 45}/month (estimated)"
      total_estimated     = "~$${(var.web_server_count * 35) + (var.db_server_count * 45)}/month"
      note               = "Estimates based on standard server pricing - actual costs may vary"
    }
  }
}

# Network Architecture
output "network_architecture" {
  description = "Network architecture and security configuration"
  value = {
    web_tier = {
      servers     = [for server in ncloud_server.web : server.name]
      private_ips = [for server in ncloud_server.web : server.private_ip]
      public_ips  = [for server in ncloud_server.web : server.public_ip]
      allowed_ports = ["80 (HTTP)", "443 (HTTPS)", "3389 (RDP from admin)"]
      security_group = ncloud_access_control_group.web.name
    }
    db_tier = {
      servers     = [for server in ncloud_server.db : server.name]
      private_ips = [for server in ncloud_server.db : server.private_ip]
      public_ips  = [for server in ncloud_server.db : server.public_ip]
      allowed_ports = ["3306 (MySQL from web tier)", "3389 (RDP from admin)"]
      security_group = ncloud_access_control_group.db.name
    }
    security_rules = {
      web_to_db_mysql = "Web servers can access DB servers on port 3306"
      admin_rdp_access = "Admin IPs (${var.admin_access_cidr}) can RDP to all servers"
      public_web_access = "Public can access web servers on ports 80/443"
    }
  }
}

# Login Key Information
output "login_key_info" {
  description = "Login key information"
  value = {
    key_name = ncloud_login_key.main.key_name
    servers_using_key = concat(
      [for server in ncloud_server.web : server.name],
      [for server in ncloud_server.db : server.name]
    )
  }
}

# Server Lists (for easy scripting)
output "server_lists" {
  description = "Simple lists of server information for scripting"
  value = {
    all_server_names = concat(
      [for server in ncloud_server.web : server.name],
      [for server in ncloud_server.db : server.name]
    )
    all_private_ips = concat(
      [for server in ncloud_server.web : server.private_ip],
      [for server in ncloud_server.db : server.private_ip]
    )
    all_public_ips = concat(
      [for server in ncloud_server.web : server.public_ip],
      [for server in ncloud_server.db : server.public_ip]
    )
    web_server_ips = [for server in ncloud_server.web : server.public_ip]
    db_server_ips  = [for server in ncloud_server.db : server.private_ip]
  }
}

# Deployment Status
output "deployment_status" {
  description = "Status of the deployment"
  value = {
    timestamp = timestamp()
    status = "Successfully deployed ${var.web_server_count} web servers and ${var.db_server_count} database servers"
    next_steps = [
      "Configure web server software (IIS, etc.)",
      "Install and configure database software (MySQL, etc.)",
      "Set up monitoring and logging",
      "Configure backup procedures",
      "Review and adjust security group rules as needed"
    ]
  }
}

# Available Options (for reference)
output "available_server_options" {
  description = "Available server images and products for reference"
  value = {
    server_images = {
      for image in data.ncloud_server_images.available.server_images :
      image.product_code => {
        name           = image.product_name
        type           = image.product_type
        os_information = try(image.os_information, "N/A")
      }
    }
    compatible_products = {
      for product in data.ncloud_server_products.compatible.server_products :
      product.product_code => {
        name        = product.product_name
        cpu_count   = product.cpu_count
        memory_size = product.memory_size
      }
    }
  }
}
