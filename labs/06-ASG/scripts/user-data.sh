#!/bin/bash

# ====================================================
# AWS Cloud & DevOps Portfolio
# Lab 06 - Amazon EC2 Auto Scaling
#
# Author : Henry Huamani
# Purpose: Configure an Apache web server dynamically
# ====================================================

set -e

# Update the operating system and install Apache
dnf update -y
dnf install httpd -y

systemctl enable httpd
systemctl start httpd

# Request an IMDSv2 session token
TOKEN=$(curl -sS --fail \
  -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

# Obtain dynamic instance information through IMDSv2
INSTANCE_ID=$(curl -sS --fail \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)

AVAILABILITY_ZONE=$(curl -sS --fail \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

PRIVATE_IP=$(curl -sS --fail \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

HOST_NAME=$(hostname)

# Create the custom web page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AWS Auto Scaling Portfolio</title>

    <style>
        body {
            background: #253142;
            color: white;
            font-family: Arial, Helvetica, sans-serif;
            text-align: center;
            padding: 80px 20px;
            margin: 0;
        }

        .card {
            width: min(700px, 85%);
            margin: auto;
            background: #3c4d63;
            padding: 40px;
            border-radius: 18px;
        }

        h1 {
            color: #ff9900;
        }

        .details {
            margin-top: 30px;
            line-height: 1.8;
        }
    </style>
</head>

<body>
    <div class="card">
        <h1>AWS Cloud Portfolio</h1>
        <h2>Amazon EC2 Auto Scaling Lab</h2>
        <h2>Auto Scaling Instance</h2>

        <div class="details">
            <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
            <p><strong>Hostname:</strong> ${HOST_NAME}</p>
            <p><strong>Private IP:</strong> ${PRIVATE_IP}</p>
            <p><strong>Availability Zone:</strong> ${AVAILABILITY_ZONE}</p>
        </div>
    </div>
</body>

</html>
EOF

systemctl restart httpd

# Verify that Apache is active
systemctl is-active --quiet httpd