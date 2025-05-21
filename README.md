# Linode Multi-Instance Manager with OpenTofu

This project automates provisioning and management of multiple Linode instances using OpenTofu (Terraform fork). It supports secure instance creation, firewall attachment, and user management—all with a flexible, map-based configuration.

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
   tofu apply -var-file="secrets.auto.tfvars"
   ```

## Example Configuration (`terraform.auto.tfvars`)
```hcl
username     = "youruser"
ssh_public_key = "ssh-ed25519 ..."
firewall_id  = "12345"
environment  = "dev"

instances = {
  web = {
    instance_type = "g6-standard-2"
    region        = "us-southeast"
    tags          = ["web"]
    label         = "dev-web-01"         # Custom label (shows in Linode)
    image         = "linode/ubuntu22.04" # Optional (default shown)
    # private_ip  = true                 # Optional (default: true)
    # backups     = false                # Optional (default: false)
  },
  app = {
    instance_type = "g6-standard-2"
    region        = "us-east"
    tags          = ["app"]
    label         = "dev-app-01"
  }
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
tofu destroy -var-file="secrets.auto.tfvars"
```

## License
[MIT](LICENSE)


4. **Initialize OpenTofu**
   ```bash
   tofu init
   ```

5. **Review the execution plan**
   ```bash
   tofu plan -var-file="secrets.tfvars"
   ```

6. **Apply the configuration**
   ```bash
   tofu apply -var-file="secrets.tfvars"
   ```

## Configuration

### terraform.tfvars.template
```hcl
# Instance Configuration
instance_label = "my-linode-instance"
instance_type = "g6-standard-1"
region       = "us-east"
image        = "linode/ubuntu22.04"
tags         = ["web", "production"]

# User Configuration
username     = "admin"
# Paste your public key between the quotes (starts with 'ssh-rsa' or similar)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... user@example.com"

# Firewall Configuration
firewall_id  = "12345"  # Replace with your existing firewall ID

# Network Configuration
private_ip   = true
backups_enabled = false
```

### secrets.tfvars.template
```hcl
# Linode API Token (sensitive)
linode_token = "your-linode-api-token-here"

# Optional: Root password (if not using SSH key auth)
# root_pass = ""
```

## Variables

### Required Variables
- `linode_token` (string): Your Linode API token with appropriate permissions
- `firewall_id` (string): ID of the existing firewall to attach
- `ssh_public_key` (string): Your public SSH key (starts with 'ssh-rsa' or similar)

### Optional Variables
- `instance_label` (string): Label for the Linode instance (default: "my-linode-instance")
- `instance_type` (string): Linode instance type (default: "g6-standard-1")
- `region` (string): Linode region (default: "us-east")
- `image` (string): OS image to use (default: "linode/ubuntu22.04")
- `username` (string): Non-root username to create (default: "admin")
- `private_ip` (bool): Whether to enable private networking (default: true)
- `backups_enabled` (bool): Whether to enable backups (default: false)
- `tags` (list): List of tags to apply to the instance

## Security Notes

1. Never commit `secrets.tfvars` or `terraform.tfvars` to version control
2. The `.gitignore` file is pre-configured to exclude these files
3. The created user will have passwordless sudo access - ensure you trust the public key being used
4. It's recommended to use a Linode API token with the minimum required permissions

## Outputs

The module will output the following:
- `instance_ip`: Public IP address of the created Linode instance
- `ssh_command`: Example SSH command to connect to the instance as the created user

## Cleanup

To destroy all created resources:

```bash
tofu destroy -var-file="secrets.tfvars"
```

## License

[MIT](LICENSE)
