# Linode Multi-Instance Manager with OpenTofu or Terraform

This project automates provisioning and management of multiple Linode instances using OpenTofu (Terraform fork) or Terraform. It supports secure instance creation, firewall attachment, and user management—all with a flexible, map-based configuration.

> **Note:** This module works with both OpenTofu and Terraform. The Quick Start examples use the `tofu` CLI, but you can use `terraform` instead—see below for details.

## Features
- Provision multiple Linode instances at once
- Per-instance custom labels, types, regions, images, and tags
- Attach all instances to an existing Linode firewall
- Automatic non-root user creation with SSH key and passwordless sudo
- Clean separation of sensitive and non-sensitive configuration

## Prerequisites
- [OpenTofu](https://opentofu.org/) installed
- Linode account and API token
- Existing Linode firewall
- SSH public key

**Example: Install OpenTofu on Ubuntu (APT method)**
```bash
# Add the OpenTofu APT repository
echo "deb [trusted=yes] https://packages.opentofu.org/opentofu/stable/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/opentofu.list

# Update package lists
sudo apt-get update

# Install OpenTofu
sudo apt-get install opentofu
```

## Project Structure
```
.
├── README.md
├── main.tf                  # Main OpenTofu configuration (multi-instance)
├── variables.tf             # Variable declarations (instances map)
├── terraform.auto.tfvars    # Your non-sensitive config (gitignored)
├── terraform.auto.tfvars.template  # Template for above
├── secrets.auto.tfvars      # Sensitive config (API token, gitignored)
├── secrets.auto.tfvars.template    # Template for above
└── .gitignore
```

## Quick Start

> **Tip:** If you prefer to use Terraform instead of OpenTofu, simply replace `tofu` with `terraform` in all commands below (e.g., `terraform init`, `terraform plan`, `terraform apply`).

1. **Clone and set up templates:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   cp terraform.auto.tfvars.template terraform.auto.tfvars
   cp secrets.auto.tfvars.template secrets.auto.tfvars
   ```
2. **Edit `terraform.auto.tfvars`:**
   - Set your `username`, `ssh_public_key`, `firewall_id`, and `environment`.
   - Define your instances in the `instances` map (see below).
3. **Edit `secrets.auto.tfvars`:**
   - Add your Linode API token.
4. **Deploy:**
   ```bash
   tofu init
   tofu plan
   tofu apply
   ```

## Example Configuration (`terraform.auto.tfvars`)
```hcl
# Environment Configuration
environment = "dev"  # or "staging", "prod", etc.

# User Configuration
username     = "admin"
# Paste your public key between the quotes (starts with 'ssh-rsa' or similar)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... user@example.com"

# Firewall Configuration
firewall_id  = "12345"  # Replace with your existing firewall ID

# Instance Configurations
instances = {
  # Basic web server example (active by default)
  web = {
    instance_type = "g6-standard-2"
    region        = "us-southeast"
    tags          = ["web"]
    label         = "my-web-server"  # Custom label for this instance
  }

  # Database server example (commented out)
  # db = {
  #   instance_type = "g6-standard-4"
  #   region        = "us-southeast"
  #   tags          = ["database"]
  #   label         = "my-database"    # Custom label for this instance
  #   backups       = true             # Enable backups for database
  # }

  # Application server example (commented out)
  # app = {
  #   instance_type = "g6-standard-2"
  #   region        = "us-southeast"
  #   tags          = ["app"]
  #   label         = "my-app-server"  # Custom label for this instance
  #   image         = "linode/ubuntu20.04"  # Optional: override default image
  #   private_ip    = true                  # Optional: enable/disable private IP
  #   backups       = false                 # Optional: enable/disable backups
  # }
}
```

## Variables
- `instances` (**map**): Keyed by instance name. Each value is an object with:
  - `label` (string, optional): Custom Linode label (recommended)
  - `instance_type` (string): Linode type (e.g., "g6-standard-2")
  - `region` (string): Linode region (e.g., "us-southeast")
  - `tags` (list): List of tags
  - `image` (string, optional): OS image (default: "linode/ubuntu22.04")
  - `private_ip` (bool, optional): Enable private networking (default: true)
  - `backups` (bool, optional): Enable backups (default: false)
- `username` (string): Non-root username to create
- `ssh_public_key` (string): Your SSH public key
- `firewall_id` (string): ID of the firewall to attach
- `environment` (string): Suffix for instance naming (e.g., "dev")

## Outputs
- `instance_ips`: Map of instance names to public IPs
- `ssh_commands`: Map of instance names to SSH commands

## Security
- Never commit `secrets.auto.tfvars` or `terraform.auto.tfvars` to version control
- `.gitignore` is pre-configured to exclude sensitive files
- The created user will have passwordless sudo—ensure you trust the SSH key
- Use a Linode API token with minimum required permissions

## Cleanup
To destroy all created resources:
```bash
tofu destroy
```

## License
[MIT](LICENSE)
