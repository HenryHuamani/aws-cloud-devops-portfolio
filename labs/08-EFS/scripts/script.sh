#!/bin/bash

# ====================================================
# AWS Cloud & DevOps Portfolio
# Lab 08 - Amazon Elastic File System (EFS)
#
# Author : Henry Huamani
# Purpose:
# Configure Apache and automatically mount Amazon EFS
# for EC2 instances launched by the Auto Scaling Group.
# ====================================================

set -e

# ----------------------------------------------------
# Variables
# ----------------------------------------------------

EFS_ID="fs-04a66a073c14f5d1c"
EFS_MOUNT="/mnt/efs"
EFS_SHARED="${EFS_MOUNT}/shared"
WEB_SHARED="/var/www/html/shared"

# ----------------------------------------------------
# Update system and install dependencies
# ----------------------------------------------------

dnf update -y

dnf install -y \
    httpd \
    amazon-efs-utils

# ----------------------------------------------------
# Configure Apache
# ----------------------------------------------------

systemctl enable httpd
systemctl start httpd

# ----------------------------------------------------
# Configure Amazon EFS
# ----------------------------------------------------

mkdir -p "${EFS_MOUNT}"

# Add the EFS mount configuration only if it does not
# already exist in /etc/fstab.
if ! grep -q "${EFS_ID}" /etc/fstab; then
    echo "${EFS_ID}:/ ${EFS_MOUNT} efs _netdev,tls 0 0" >> /etc/fstab
fi

# Mount EFS only if the mount point is not already mounted.
if ! mountpoint -q "${EFS_MOUNT}"; then
    mount "${EFS_MOUNT}"
fi

# ----------------------------------------------------
# Configure shared application storage
# ----------------------------------------------------

mkdir -p "${EFS_SHARED}"

# Remove an existing local path or symbolic link before
# creating the shared Apache path.
if [ -e "${WEB_SHARED}" ] || [ -L "${WEB_SHARED}" ]; then
    rm -rf "${WEB_SHARED}"
fi

ln -s "${EFS_SHARED}" "${WEB_SHARED}"

# ----------------------------------------------------
# Retrieve EC2 metadata using IMDSv2
# ----------------------------------------------------

TOKEN=$(curl -sS --fail \
    -X PUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    http://169.254.169.254/latest/api/token)

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

# ----------------------------------------------------
# Create the local Apache landing page
# ----------------------------------------------------

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AWS Cloud Portfolio</title>

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

        <h2>Amazon EC2 Auto Scaling + Amazon EFS</h2>

        <div class="details">

            <p>
                <strong>Instance ID:</strong>
                ${INSTANCE_ID}
            </p>

            <p>
                <strong>Hostname:</strong>
                ${HOST_NAME}
            </p>

            <p>
                <strong>Private IP:</strong>
                ${PRIVATE_IP}
            </p>

            <p>
                <strong>Availability Zone:</strong>
                ${AVAILABILITY_ZONE}
            </p>

            <p>
                <strong>Shared Storage:</strong>
                Amazon EFS
            </p>

        </div>

    </div>

</body>

</html>
EOF

# ----------------------------------------------------
# Restart Apache
# ----------------------------------------------------

systemctl restart httpd

# ----------------------------------------------------
# Validation
# ----------------------------------------------------

systemctl is-active --quiet httpd

mountpoint -q "${EFS_MOUNT}"

test -L "${WEB_SHARED}"

echo "Lab 08 bootstrap completed successfully."