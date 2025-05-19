terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.13.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "linode" {
  token = var.linode_token
}

# Create the Linode instance
resource "linode_instance" "web" {
  label            = var.instance_label
  region           = var.region
  type             = var.instance_type
  private_ip       = var.private_ip
  backups_enabled  = var.backups_enabled
  tags             = var.tags
  image            = var.image
  authorized_keys  = [var.ssh_public_key]
  
  # User data for cloud-init
  metadata {
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      username       = var.username
      ssh_public_key = var.ssh_public_key
    }))
  }
}

# Attach to the specified firewall
resource "linode_firewall_device" "web" {
  firewall_id = var.firewall_id
  entity_id   = linode_instance.web.id
}

# Output the instance IP and SSH command
output "instance_ip" {
  value       = linode_instance.web.ip_address
  description = "The public IP address of the Linode instance"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/linode/id_ed25519 ${var.username}@${linode_instance.web.ip_address}"
  description = "Command to SSH into the instance as the created user"
  
  depends_on = [
    linode_instance.web
  ]
}
