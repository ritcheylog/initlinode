# Linode Instance Manager with OpenTofu

This OpenTofu project automates the provisioning of Linode instances with secure configurations, including firewall attachment and user management.

## Features

- Create Linode instances with custom specifications
- Attach instances to existing Linode firewalls
- Automatically create a non-root user with:
  - Passwordless SSH authentication using your public key
  - Passwordless sudo privileges
- Secure configuration separation using multiple variable files

## Prerequisites

- [OpenTofu](https://opentofu.org/) installed on your local machine
- A Linode account with API access
- Linode API token with appropriate permissions
- Existing firewall in Linode that you want to attach to the instance
- SSH public key for authentication

## Project Structure

```
.
├── README.md
├── main.tf              # Main OpenTofu configuration
├── variables.tf         # Variable declarations
├── terraform.tfvars     # Default variable values (gitignored)
├── terraform.tfvars.template  # Template for terraform.tfvars
├── secrets.tfvars.template    # Template for secrets.tfvars
└── .gitignore          # Git ignore file
```

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Copy the template files**
   ```bash
   cp terraform.tfvars.template terraform.tfvars
   cp secrets.tfvars.template secrets.tfvars
   ```

3. **Configure your variables**
   - Edit `terraform.tfvars` with your non-sensitive configuration
   - Edit `secrets.tfvars` with your sensitive information (API tokens, etc.)

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
