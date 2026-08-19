#!/bin/bash
#
# NovaCommerce – Lab 09
# EC2 Launch Template User Data
#
# Purpose:
# - Update the operating system
# - Install and start Apache
# - Retrieve EC2 metadata using IMDSv2
# - Generate a validation page identifying the backend instance
#
# Intended for Amazon Linux 2023 / dnf-based Amazon Linux environments.

set -e

# Update packages
dnf update -y

# Install Apache
dnf install -y httpd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Request an IMDSv2 token
TOKEN=$(curl -sS -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

# Retrieve instance metadata
INSTANCE_ID=$(curl -sS \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)

AVAILABILITY_ZONE=$(curl -sS \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

PRIVATE_IP=$(curl -sS \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

# Generate the NovaCommerce validation page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaCommerce – AWS Lab 09</title>
</head>
<body>
    <h1>NovaCommerce</h1>
    <h2>Highly Available Web Architecture</h2>

    <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
    <p><strong>Availability Zone:</strong> ${AVAILABILITY_ZONE}</p>
    <p><strong>Private IP:</strong> ${PRIVATE_IP}</p>
    <p><strong>Shared Storage:</strong> Amazon EFS</p>

    <hr>
    <p>Lab 09 – Application Load Balancer + EC2 Auto Scaling</p>
</body>
</html>
EOF

# Ensure Apache is running after page creation
systemctl restart httpd

# Local validation
curl -f http://localhost/ >/dev/null

echo "NovaCommerce web server initialization completed."
