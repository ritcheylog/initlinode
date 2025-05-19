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

# Optional Variables

variable "instance_label" {
  description = "Label for the Linode instance"
  type        = string
  default     = "my-linode-instance"
}

variable "instance_type" {
  description = "Linode instance type"
  type        = string
  default     = "g6-standard-1"
}

variable "region" {
  description = "Linode region"
  type        = string
  default     = "us-east"
}

variable "image" {
  description = "OS image to use"
  type        = string
  default     = "linode/ubuntu22.04"
}

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
