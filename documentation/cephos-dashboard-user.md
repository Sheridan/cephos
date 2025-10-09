# cephos-dashboard-user

## Description
The `cephos-dashboard-user` script manages users for the Ceph Manager Dashboard. It can create new users or update existing user passwords.

## Options
- `-u <user>`: Specify the username (default: `cephos`)
- `-p <password>`: Specify the password
- `-r <role>`: Specify the role (default: `administrator`)
- `-h`: Show this help message
- `-v`: Enable verbose output

## Examples
```bash
# Create a new dashboard user
cephos-dashboard-user -u myuser -p mypassword -r administrator

# Update an default user (cephos) password
cephos-dashboard-user -p newpassword
```

## Functionality
1. Validates that a password is provided
1. Checks if the user already exists in the dashboard
1. If user exists:
   - Updates the user's password
1. If user doesn't exist:
   - Creates a new user with the specified role

## User Management
- Supports creating and updating Ceph dashboard users
- Allows setting custom roles and passwords
- Uses a temporary file to handle password input securely
