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
  image            = var.image
  region           = var.region
  type             = var.instance_type
  root_pass        = var.root_pass
  authorized_keys  = [var.ssh_public_key]
  private_ip       = var.private_ip
  backups_enabled  = var.backups_enabled
  tags             = var.tags
  
  # Configure the disk and boot settings
  disk {
    label            = "boot"
    size             = linode_instance.web.specs.0.disk
    image            = var.image
    root_pass        = var.root_pass
    authorized_keys  = [var.ssh_public_key]
    authorized_users  = []
    stackscript_id   = linode_stackscript.user_setup.id
  }

  # Configure the network interface
  config {
    label  = "boot_config"
    kernel = "linode/grub2"
    devices {
      sda {
        disk_label = "boot"
      }
    }
    helpers {
      updatedb_disabled    = true
      distro               = true
      modules_dep          = true
      network              = true
      devtmpfs_automount   = false
    }
  }

  # Attach to the specified firewall
  provisioner "local-exec" {
    command = <<EOT
      curl -H "Authorization: Bearer ${var.linode_token}" \
           -H "Content-Type: application/json" \
           -X POST \
           -d '{"id": ${var.firewall_id}}' \
           https://api.linode.com/v4/linode/instances/${self.id}/firewalls
    EOT
  }
}

# StackScript to set up the non-root user with passwordless sudo and SSH access
resource "linode_stackscript" "user_setup" {
  label        = "user-setup-script"
  description  = "Sets up a non-root user with passwordless sudo and SSH access"
  script       = <<-EOT
    #!/bin/bash
    # <UDF name="username" label="Username" default="admin" />
    # <UDF name="ssh_public_key" label="SSH Public Key" />

    
    # Update and install required packages
    apt-get update
    apt-get install -y sudo
    
    # Create user and add to sudo group
    useradd -m -s /bin/bash $USERNAME
    usermod -aG sudo $USERNAME
    
    # Set up passwordless sudo
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USERNAME
    chmod 0440 /etc/sudoers.d/90-$USERNAME
    
    # Set up SSH directory and authorized_keys
    USER_HOME=$(getent passwd $USERNAME | cut -d: -f6)
    mkdir -p $USER_HOME/.ssh
    echo "$SSH_PUBLIC_KEY" > $USER_HOME/.ssh/authorized_keys
    
    # Set proper permissions
    chown -R $USERNAME:$USERNAME $USER_HOME/.ssh
    chmod 700 $USER_HOME/.ssh
    chmod 600 $USER_HOME/.ssh/authorized_keys
    
    # Disable password authentication for SSH
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    echo "User setup complete!"
  EOT
  images      = ["linode/ubuntu22.04", "linode/ubuntu20.04"]
  rev_note   = "Initial version"
  
  lifecycle {
    create_before_destroy = true
  }
}

# Output the instance IP and SSH command
output "instance_ip" {
  value       = linode_instance.web.ip_address
  description = "The public IP address of the Linode instance"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/private_key ${var.username}@${linode_instance.web.ip_address}"
  description = "Command to SSH into the instance as the created user"
  
  depends_on = [
    linode_instance.web
  ]
}
