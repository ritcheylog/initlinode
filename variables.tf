# Required Variables

variable "linode_token" {
  description = "Your Linode API token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "firewall_id" {
  description = "ID of the existing firewall to attach"
  type        = string
}

variable "ssh_public_key" {
  description = "Your public SSH key (starts with 'ssh-rsa' or similar)"
  type        = string
  sensitive   = true
}

# Instance Configuration

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instances" {
  description = "Map of instance configurations"
  type = map(object({
    instance_type = string
    region        = string
    tags          = list(string)
    image         = optional(string, "linode/ubuntu22.04")
    private_ip    = optional(bool, true)
    backups       = optional(bool, false)
    label         = optional(string, "")  # Optional custom label for the instance
  }))
  default = {
    web = {
      instance_type = "g6-standard-2"
      region        = "us-southeast"
      tags          = ["web"]
      label         = "web-server"  # Default label if not specified
    },
    db = {
      instance_type = "g6-standard-2"
      region        = "us-southeast"
      tags          = ["database"]
      label         = "database-server"  # Default label if not specified
    }
  }
}

# User Configuration

variable "username" {
  description = "Non-root username to create"
  type        = string
  default     = "admin"
}

variable "private_ip" {
  description = "Whether to enable private networking"
  type        = bool
  default     = true
}

variable "backups_enabled" {
  description = "Whether to enable backups"
  type        = bool
  default     = false
}

variable "tags" {
  description = "List of tags to apply to the instance"
  type        = list(string)
  default     = ["web", "production"]
}

variable "root_pass" {
  description = "Root password (optional, only needed if not using SSH key auth)"
  type        = string
  default     = ""
  sensitive   = true
}
