# Output Values for Complete VPC Infrastructure
# Comprehensive information about the created VPC environment

# Network Infrastructure Information
output "network_infrastructure" {
  description = "Complete network infrastructure details"
  value = {
    vpc = {
      id              = ncloud_vpc.main.id
      name            = ncloud_vpc.main.name
      cidr_block      = ncloud_vpc.main.ipv4_cidr_block
      default_acl_no  = ncloud_vpc.main.default_network_acl_no
    }
    
    internet_gateway = {
      id     = ncloud_internet_gateway.main.id
      vpc_no = ncloud_internet_gateway.main.vpc_no
    }
    
    nat_gateway = {
      id        = ncloud_nat_gateway.main.id
      name      = ncloud_nat_gateway.main.name
      public_ip = ncloud_nat_gateway.main.public_ip
      vpc_no    = ncloud_nat_gateway.main.vpc_no
      subnet_no = ncloud_nat_gateway.main.subnet_no
    }
    
    public_subnet = {
      id                = ncloud_subnet.public.id
      name              = ncloud_subnet.public.name
      cidr_block        = ncloud_subnet.public.subnet
      zone              = ncloud_subnet.public.zone
      available_ip_count = ncloud_subnet.public.available_ip_count
    }
    
    private_subnet = {
      id                = ncloud_subnet.private.id
      name              = ncloud_subnet.private.name
      cidr_block        = ncloud_subnet.private.subnet
      zone              = ncloud_subnet.private.zone
      available_ip_count = ncloud_subnet.private.available_ip_count
    }
    
    route_tables = {
      public = {
        id   = ncloud_route_table.public.id
        name = ncloud_route_table.public.name
        type = "PUBLIC"
      }
      private = {
        id   = ncloud_route_table.private.id
        name = ncloud_route_table.private.name
        type = "PRIVATE"
      }
    }
  }
}

# Security Groups Information
output "security_groups" {
  description = "Security group configurations and rules"
  value = {
    web = {
      id          = ncloud_access_control_group.web.id
      name        = ncloud_access_control_group.web.name
      description = ncloud_access_control_group.web.description
      vpc_no      = ncloud_access_control_group.web.vpc_no
      rules       = ["HTTP(80) from 0.0.0.0/0", "HTTPS(443) from 0.0.0.0/0", "RDP(3389) from admin/bastion"]
    }
    
    database = {
      id          = ncloud_access_control_group.database.id
      name        = ncloud_access_control_group.database.name
      description = ncloud_access_control_group.database.description
      vpc_no      = ncloud_access_control_group.database.vpc_no
      rules       = ["MySQL(3306) from web SG", "SQL Server(1433) from web SG", "RDP(3389) from bastion SG"]
    }
    
    bastion = var.create_bastion ? {
      id          = ncloud_access_control_group.bastion.id
      name        = ncloud_access_control_group.bastion.name
      description = ncloud_access_control_group.bastion.description
      vpc_no      = ncloud_access_control_group.bastion.vpc_no
      rules       = ["RDP(3389) from admin", "SSH(22) from admin"]
    } : null
  }
}

# Server Information by Tier
output "servers_by_tier" {
  description = "Detailed server information organized by tier"
  value = {
    bastion = var.create_bastion ? {
      for idx, server in ncloud_server.bastion : "bastion-${idx + 1}" => {
        id              = server.id
        instance_no     = server.instance_no
        name            = server.name
        private_ip      = server.private_ip
        public_ip       = ncloud_public_ip.bastion[idx].public_ip
        subnet_no       = server.subnet_no
        subnet_name     = ncloud_subnet.public.name
        cpu_count       = server.cpu_count
        memory_size     = server.memory_size
        zone            = server.zone
        platform        = server.platform_type
        security_groups = [ncloud_access_control_group.bastion.name]
        role            = "bastion"
      }
    } : {}
    
    web = {
      for idx, server in ncloud_server.web : "web-${idx + 1}" => {
        id              = server.id
        instance_no     = server.instance_no
        name            = server.name
        private_ip      = server.private_ip
        public_ip       = ncloud_public_ip.web[idx].public_ip
        subnet_no       = server.subnet_no
        subnet_name     = ncloud_subnet.public.name
        cpu_count       = server.cpu_count
        memory_size     = server.memory_size
        zone            = server.zone
        platform        = server.platform_type
        security_groups = [ncloud_access_control_group.web.name]
        role            = "web"
      }
    }
    
    database = {
      for idx, server in ncloud_server.database : "db-${idx + 1}" => {
        id              = server.id
        instance_no     = server.instance_no
        name            = server.name
        private_ip      = server.private_ip
        public_ip       = null  # No public IP for database servers
        subnet_no       = server.subnet_no
        subnet_name     = ncloud_subnet.private.name
        cpu_count       = server.cpu_count
        memory_size     = server.memory_size
        zone            = server.zone
        platform        = server.platform_type
        security_groups = [ncloud_access_control_group.database.name]
        role            = "database"
      }
    }
  }
}

# Connection Information
output "connection_guide" {
  description = "Step-by-step connection guide for different access scenarios"
  value = {
    direct_web_access = {
      description = "Direct access to web servers from internet"
      web_servers = {
        for idx, server in ncloud_server.web : server.name => {
          http_url  = "http://${ncloud_public_ip.web[idx].public_ip}"
          https_url = "https://${ncloud_public_ip.web[idx].public_ip}"
          rdp_connection = "mstsc /v:${ncloud_public_ip.web[idx].public_ip}:3389"
          public_ip = ncloud_public_ip.web[idx].public_ip
        }
      }
    }
    
    bastion_access = var.create_bastion ? {
      description = "Access private resources through bastion host"
      bastion_host = {
        public_ip = ncloud_public_ip.bastion[0].public_ip
        rdp_command = "mstsc /v:${ncloud_public_ip.bastion[0].public_ip}:3389"
        ssh_command = "ssh administrator@${ncloud_public_ip.bastion[0].public_ip}"
      }
      database_servers = {
        for idx, server in ncloud_server.database : server.name => {
          private_ip = server.private_ip
          access_note = "Connect to bastion first, then RDP to ${server.private_ip}:3389"
          mysql_connection = "mysql -h ${server.private_ip} -P 3306 -u username -p"
          sqlserver_connection = "sqlcmd -S ${server.private_ip},1433 -U username -P password"
        }
      }
    } : null
    
    admin_access_requirements = {
      description = "Requirements for administrative access"
      allowed_cidr = var.admin_access_cidr
      note = var.admin_access_cidr == "0.0.0.0/0" ? "WARNING: Admin access is open to all IPs. Consider restricting to your office IP." : "Admin access restricted to ${var.admin_access_cidr}"
      recommendation = "Set admin_access_cidr to your office IP range (e.g., '203.248.252.0/24')"
    }
  }
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "High-level infrastructure summary with costs"
  value = {
    environment = var.environment
    project_name = var.project_name
    
    network = {
      vpc_cidr = var.vpc_cidr
      public_subnet_cidr = var.public_subnet_cidr
      private_subnet_cidr = var.private_subnet_cidr
      zone = var.zone
    }
    
    servers = {
      total_count = var.web_server_count + var.db_server_count + (var.create_bastion ? 1 : 0)
      bastion_count = var.create_bastion ? 1 : 0
      web_count = var.web_server_count
      database_count = var.db_server_count
    }
    
    security = {
      security_groups = 3
      bastion_enabled = var.create_bastion
      admin_access_restricted = var.admin_access_cidr != "0.0.0.0/0"
    }
    
    estimated_monthly_cost = {
      bastion = var.create_bastion ? "~$25/month" : "$0/month"
      web_servers = "~$${var.web_server_count * 35}/month"
      database_servers = "~$${var.db_server_count * 45}/month"
      nat_gateway = "~$15/month"
      public_ips = "~$${(var.web_server_count + (var.create_bastion ? 1 : 0)) * 3}/month"
      total_estimated = "~$${(var.create_bastion ? 25 : 0) + (var.web_server_count * 35) + (var.db_server_count * 45) + 15 + ((var.web_server_count + (var.create_bastion ? 1 : 0)) * 3)}/month"
      note = "Estimates based on standard pricing - actual costs may vary"
    }
  }
}

# Network Architecture Diagram
output "network_architecture_diagram" {
  description = "Text-based network architecture diagram"
  value = <<-EOT
    VPC (${var.vpc_cidr})
    ├── Internet Gateway
    ├── Public Subnet (${var.public_subnet_cidr})
    │   ├── NAT Gateway (${ncloud_nat_gateway.main.public_ip})
    │   ├── Web Servers [${var.web_server_count}] (${join(", ", [for server in ncloud_server.web : server.private_ip])})
    │   ${var.create_bastion ? "└── Bastion Host (${ncloud_server.bastion[0].private_ip})" : ""}
    └── Private Subnet (${var.private_subnet_cidr})
        └── Database Servers [${var.db_server_count}] (${join(", ", [for server in ncloud_server.database : server.private_ip])})
    
    Security Groups:
    - Web SG: HTTP(80), HTTPS(443), RDP(3389) from admin/bastion
    - DB SG: MySQL(3306), SQL Server(1433) from web SG, RDP from bastion
    ${var.create_bastion ? "- Bastion SG: RDP(3389), SSH(22) from admin IPs" : ""}
    
    Public IPs:
    ${join("\n    ", [for idx, ip in ncloud_public_ip.web : "- Web-${idx + 1}: ${ip.public_ip}"])}
    ${var.create_bastion ? "- Bastion: ${ncloud_public_ip.bastion[0].public_ip}" : ""}
  EOT
}

# Deployment Status and Next Steps
output "deployment_status" {
  description = "Deployment status and recommended next steps"
  value = {
    status = "Successfully deployed complete VPC infrastructure"
    timestamp = timestamp()
    
    created_resources = [
      "1 VPC with Internet Gateway and NAT Gateway",
      "2 Subnets (1 public, 1 private) with route tables",
      "3 Security Groups with comprehensive rules",
      "${var.create_bastion ? 1 : 0} Bastion Host in public subnet",
      "${var.web_server_count} Web Servers in public subnet",
      "${var.db_server_count} Database Servers in private subnet",
      "${var.web_server_count + (var.create_bastion ? 1 : 0)} Public IP addresses"
    ]
    
    next_steps = [
      "Configure web server software (IIS, Apache, Nginx)",
      "Install and configure database software (MySQL, SQL Server)",
      "Set up SSL certificates for HTTPS",
      "Configure load balancer for web servers",
      "Implement backup and monitoring solutions",
      "Review and harden security group rules",
      "Set up CI/CD pipelines for application deployment"
    ]
    
    security_recommendations = [
      var.admin_access_cidr == "0.0.0.0/0" ? "⚠URGENT: Restrict admin_access_cidr to your office IP range" : "Admin access properly restricted",
      var.create_bastion ? "Bastion host created for secure access to private resources" : "Consider enabling bastion host for better security",
      "Database servers isolated in private subnet",
      "Security groups follow principle of least privilege",
      "Consider implementing VPN for additional security"
    ]
  }
}

# Resource Management Information
output "resource_management" {
  description = "Information for managing and maintaining the infrastructure"
  value = {
    terraform_state = {
      managed_resources = length([
        ncloud_vpc.main,
        ncloud_internet_gateway.main,
        ncloud_nat_gateway.main,
        ncloud_subnet.public,
        ncloud_subnet.private
      ]) + length(ncloud_server.web) + length(ncloud_server.database) + (var.create_bastion ? length(ncloud_server.bastion) : 0)
      
      key_resources = [
        "VPC and networking components",
        "Security groups and rules",
        "Servers and public IPs",
        "Route tables and associations"
      ]
    }
    
    scaling_options = {
      web_servers = "Modify web_server_count variable (current: ${var.web_server_count})"
      database_servers = "Modify db_server_count variable (current: ${var.db_server_count})"
      server_specs = "Update server_product_code variables for different specifications"
      security_rules = "Add/modify security group rules in main.tf"
    }
    
    cost_optimization = [
      "Use smaller server specifications for development environments",
      "Consider scheduled start/stop for non-production servers",
      "Monitor NAT Gateway usage and optimize if needed",
      "Review and release unused public IP addresses"
    ]
    
    backup_considerations = [
      "Database servers: Implement automated database backups",
      "Web servers: Consider server image snapshots",
      "Configuration: Keep Terraform state file backed up",
      "SSL certificates: Maintain backup of certificates and keys"
    ]
  }
}
