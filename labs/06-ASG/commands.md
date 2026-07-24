# Commands Reference

This document contains the Linux commands and configuration steps used throughout **Lab 06 – Amazon EC2 Auto Scaling**.

---

# Table of Contents

- System Update
- Apache Installation
- Apache Service Management
- User Data
- IMDSv2 Metadata
- HTML Page Creation
- Verification Commands
- Networking Commands
- Troubleshooting Commands

---

# System Update

Update the operating system packages.

```bash
sudo dnf update -y
```

---

# Apache Installation

Install Apache HTTP Server.

```bash
sudo dnf install httpd -y
```

Verify Apache installation.

```bash
httpd -v
```

---

# Apache Service Management

Enable Apache at boot.

```bash
sudo systemctl enable httpd
```

Start Apache.

```bash
sudo systemctl start httpd
```

Restart Apache.

```bash
sudo systemctl restart httpd
```

Stop Apache.

```bash
sudo systemctl stop httpd
```

Check Apache status.

```bash
sudo systemctl status httpd
```

---

# User Data Script

The following script was configured inside the Launch Template to automatically provision every EC2 instance.

```bash
#!/bin/bash

dnf update -y
dnf install -y httpd

TOKEN=$(curl -X PUT \
"http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/instance-id)

HOSTNAME=$(hostname)

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/local-ipv4)

AZ=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<html>
<head>
<title>AWS Auto Scaling</title>
</head>

<body>

<h1>Amazon EC2 Auto Scaling</h1>

<h2>Lab 06</h2>

<p><b>Instance ID:</b> $INSTANCE_ID</p>
<p><b>Hostname:</b> $HOSTNAME</p>
<p><b>Private IP:</b> $PRIVATE_IP</p>
<p><b>Availability Zone:</b> $AZ</p>

</body>
</html>
EOF

systemctl enable httpd
systemctl start httpd
```

---

# IMDSv2 Commands

Create session token.

```bash
TOKEN=$(curl -X PUT \
"http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds:21600")
```

Retrieve Instance ID.

```bash
curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/instance-id
```

Retrieve Private IP.

```bash
curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/local-ipv4
```

Retrieve Availability Zone.

```bash
curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/placement/availability-zone
```

Retrieve Hostname.

```bash
hostname
```

---

# HTML Verification

View generated HTML.

```bash
cat /var/www/html/index.html
```

Open locally.

```bash
curl localhost
```

---

# Service Verification

Check Apache service.

```bash
systemctl status httpd
```

Check listening port.

```bash
ss -tlnp
```

Verify HTTP port.

```bash
sudo ss -tlnp | grep :80
```

---

# Networking Commands

Display IP address.

```bash
ip addr
```

Display routing table.

```bash
ip route
```

Test internet connectivity.

```bash
ping google.com
```

---

# Log Inspection

Cloud-init log.

```bash
sudo cat /var/log/cloud-init.log
```

Cloud-init output.

```bash
sudo cat /var/log/cloud-init-output.log
```

Apache log.

```bash
sudo journalctl -u httpd
```

System log.

```bash
sudo journalctl -xe
```

---

# Troubleshooting Commands

Check User Data execution.

```bash
sudo cloud-init status
```

Restart cloud-init (testing only).

```bash
sudo cloud-init clean
```

```bash
sudo reboot
```

Verify Apache process.

```bash
ps -ef | grep httpd
```

Verify installed package.

```bash
rpm -qa | grep httpd
```

---

# Useful AWS Console Actions

During this laboratory the following AWS Console components were configured:

- Launch Template
- Auto Scaling Group
- Application Load Balancer
- Target Group
- Health Checks
- Security Groups
- Amazon VPC
- Public Subnets

---

# Summary

This command reference provides a quick lookup for the Linux commands and AWS-related configuration used throughout Lab 06. It can be reused as a practical reference when deploying future Auto Scaling environments.