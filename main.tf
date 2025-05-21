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

# Create multiple Linode instances
resource "linode_instance" "servers" {
  for_each = var.instances

  # Use custom label if provided, otherwise use the default naming convention
  label = each.value.label != "" ? each.value.label : "${each.key}-${var.environment}"
  region          = each.value.region
  type            = each.value.instance_type
  private_ip      = lookup(each.value, "private_ip", true)
  backups_enabled = lookup(each.value, "backups", false)
  tags            = concat(each.value.tags, [var.environment])
  image           = lookup(each.value, "image", "linode/ubuntu22.04")
  authorized_keys = [var.ssh_public_key]
  
  metadata {
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      username       = var.username
      ssh_public_key = var.ssh_public_key
    }))
  }
}

# Attach instances to the specified firewall
resource "linode_firewall_device" "servers" {
  for_each   = var.instances
  firewall_id = var.firewall_id
  entity_id   = linode_instance.servers[each.key].id
}

# Output all instance IPs
output "instance_ips" {
  value = {
    for k, instance in linode_instance.servers : k => instance.ip_address
  }
  description = "Map of instance names to their public IP addresses"
}

# Output SSH commands for all instances
output "ssh_commands" {
  value = {
    for k, instance in linode_instance.servers : k => "ssh -i ~/.ssh/linode/id_ed25519 ${var.username}@${instance.ip_address}"
  }
  description = "Map of instance names to their SSH commands"
}
