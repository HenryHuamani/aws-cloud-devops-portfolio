# Commands – Lab 09

This file documents the main Linux commands and validation commands used during Lab 09 to configure, test, and validate the NovaCommerce highly available and Auto Scaling web architecture.

> **Lab:** Lab 09 – Amazon CloudWatch Monitoring, Alarms & Auto Scaling Validation  
> **Region:** `us-east-2`  
> **Environment:** NovaCommerce

---

# 1. System Update

Update the EC2 operating system packages:

```bash
sudo dnf update -y
```

---

# 2. Apache Web Server

## Install Apache

```bash
sudo dnf install -y httpd
```

## Enable Apache at Boot

```bash
sudo systemctl enable httpd
```

## Start Apache

```bash
sudo systemctl start httpd
```

## Check Apache Status

```bash
sudo systemctl status httpd
```

## Restart Apache

```bash
sudo systemctl restart httpd
```

## Stop Apache

Used during controlled availability testing when required:

```bash
sudo systemctl stop httpd
```

## Start Apache Again

```bash
sudo systemctl start httpd
```

---

# 3. Validate Local Web Service

Test the Apache service directly from the EC2 instance:

```bash
curl http://localhost
```

Check only the HTTP response headers:

```bash
curl -I http://localhost
```

A successful response should normally include:

```text
HTTP/1.1 200 OK
```

---

# 4. EC2 Instance Metadata – IMDSv2

The Launch Template User Data uses Instance Metadata Service Version 2 (IMDSv2) to obtain information about each EC2 instance.

## Request Metadata Token

```bash
TOKEN=$(curl -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)
```

## Retrieve Instance ID

```bash
INSTANCE_ID=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
```

Display the value:

```bash
echo "$INSTANCE_ID"
```

## Retrieve Availability Zone

```bash
AVAILABILITY_ZONE=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
```

Display the value:

```bash
echo "$AVAILABILITY_ZONE"
```

## Retrieve Private IPv4 Address

```bash
PRIVATE_IP=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)
```

Display the value:

```bash
echo "$PRIVATE_IP"
```

---

# 5. Generate the Web Validation Page

The EC2 instances display infrastructure information that makes it possible to verify which backend instance handled an ALB request.

Example:

```bash
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>NovaCommerce AWS Portfolio</title>
</head>
<body>
    <h1>NovaCommerce</h1>
    <p>Instance ID: $INSTANCE_ID</p>
    <p>Availability Zone: $AVAILABILITY_ZONE</p>
    <p>Private IP: $PRIVATE_IP</p>
    <p>Shared Storage: Amazon EFS</p>
</body>
</html>
EOF
```

Validate the generated file:

```bash
cat /var/www/html/index.html
```

Test the page locally:

```bash
curl http://localhost
```

---

# 6. Amazon EFS

Amazon EFS provides shared storage to the EC2 application tier.

## Install EFS/NFS Utilities

For Amazon Linux:

```bash
sudo dnf install -y amazon-efs-utils
```

If NFS utilities are required:

```bash
sudo dnf install -y nfs-utils
```

## Create Mount Directory

```bash
sudo mkdir -p /mnt/efs
```

## Check Mounted File Systems

```bash
df -h
```

Filter EFS-related mounts:

```bash
mount | grep efs
```

or:

```bash
df -h | grep efs
```

## Validate Shared Storage

Create a validation file on the mounted EFS filesystem:

```bash
echo "NovaCommerce shared storage test" | sudo tee /mnt/efs/shared-test.txt
```

Read the file:

```bash
cat /mnt/efs/shared-test.txt
```

The same file can be read from another EC2 instance connected to the same EFS filesystem, demonstrating shared storage.

## Check Mount Directory

```bash
ls -lah /mnt/efs
```

---

# 7. CPU Stress Test

A controlled CPU stress test was used to validate the Auto Scaling Target Tracking policy.

## Install stress-ng

```bash
sudo dnf install -y stress-ng
```

Verify installation:

```bash
stress-ng --version
```

## Generate CPU Load

Example CPU stress test:

```bash
stress-ng --cpu 2 --timeout 600s
```

A longer test can be used when CloudWatch requires additional datapoints:

```bash
stress-ng --cpu 2 --timeout 900s
```

> The workload should only be maintained long enough to validate the scaling policy.

## Stop stress-ng Manually

If necessary:

```bash
sudo pkill stress-ng
```

## Verify stress-ng Processes

```bash
ps aux | grep stress-ng
```

---

# 8. CPU Utilization Validation

View active processes:

```bash
top
```

Alternative:

```bash
uptime
```

Display CPU information:

```bash
lscpu
```

These commands help confirm that CPU load is being generated locally before validating the corresponding CloudWatch metrics.

---

# 9. Application Load Balancer Validation

The ALB DNS endpoint is used to validate application availability.

Example:

```bash
curl http://<ALB-DNS-NAME>
```

Repeat the request several times:

```bash
for i in {1..10}; do
  curl -s http://<ALB-DNS-NAME>
  echo
done
```

Because the page contains the EC2 Instance ID and Availability Zone, repeated requests can demonstrate that the Application Load Balancer is forwarding traffic to different backend instances.

---

# 10. Health Check Validation

The Target Group Health Check uses:

```text
Protocol: HTTP
Path: /
Port: Traffic Port
Success Code: 200
```

Validate the application locally:

```bash
curl -I http://localhost/
```

Expected result:

```text
HTTP/1.1 200 OK
```

---

# 11. Controlled Unhealthy Target Test

Stopping Apache can be used as a controlled test to make an EC2 target fail the ALB application Health Check:

```bash
sudo systemctl stop httpd
```

Verify:

```bash
sudo systemctl status httpd
```

After the validation, Apache can be restored with:

```bash
sudo systemctl start httpd
```

> During the laboratory, Target Group health and Auto Scaling activity were monitored from AWS while the failure scenario was performed.

---

# 12. Network Validation

## Display Network Interfaces

```bash
ip addr
```

## Display Routing Table

```bash
ip route
```

## Display Hostname

```bash
hostname
```

## Test DNS Resolution

```bash
getent hosts <ALB-DNS-NAME>
```

## Test HTTP Connectivity

```bash
curl -I http://<ALB-DNS-NAME>
```

---

# 13. Port Validation

Check listening TCP ports:

```bash
sudo ss -tulpn
```

Check Apache specifically:

```bash
sudo ss -tulpn | grep ':80'
```

Expected web listener:

```text
TCP 80
```

---

# 14. Service Logs

Review Apache service logs through systemd:

```bash
sudo journalctl -u httpd
```

Show recent entries:

```bash
sudo journalctl -u httpd -n 50
```

Follow logs in real time:

```bash
sudo journalctl -u httpd -f
```

---

# 15. System Validation

Check system uptime:

```bash
uptime
```

Check memory:

```bash
free -h
```

Check disk usage:

```bash
df -h
```

Check running services:

```bash
systemctl --type=service --state=running
```

---

# 16. Auto Scaling Validation Workflow

The practical validation performed in the laboratory followed this sequence:

```text
1. Confirm baseline capacity
        ↓
2. Confirm 2 healthy EC2 instances
        ↓
3. Generate CPU load with stress-ng
        ↓
4. Observe CPU utilization increase
        ↓
5. Wait for CloudWatch / Target Tracking
        ↓
6. Confirm scale-out activity
        ↓
7. Confirm capacity increased to 4 instances
        ↓
8. Stop CPU stress
        ↓
9. Observe CPU utilization decrease
        ↓
10. Wait for stabilization
        ↓
11. Confirm scale-in activity
        ↓
12. Confirm baseline capacity restored
```

No manual desired-capacity reduction should be performed during the scale-in validation because doing so would invalidate the automatic scaling test.

---

# 17. Multi-AZ Validation Workflow

The final load-balancing validation followed this process:

```text
ALB DNS
   │
   ├── Request → EC2 Instance → us-east-2a
   │
   └── Request → EC2 Instance → us-east-2b
```

The application page exposes:

```text
Instance ID
Availability Zone
Private IP
Shared Storage
```

This allows visual confirmation that requests are being processed by different EC2 instances in different Availability Zones.

---

# 18. Useful Troubleshooting Commands

## Apache Is Not Responding

```bash
sudo systemctl status httpd
```

```bash
sudo journalctl -u httpd -n 100
```

```bash
sudo ss -tulpn | grep ':80'
```

```bash
curl -I http://localhost
```

## EFS Is Not Visible

```bash
df -h
```

```bash
mount | grep efs
```

```bash
ls -lah /mnt/efs
```

## CPU Stress Is Still Running

```bash
ps aux | grep stress-ng
```

Stop it:

```bash
sudo pkill stress-ng
```

## Confirm Current Instance Identity

```bash
TOKEN=$(curl -s -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id
```

---

# Important Notes

- Replace `<ALB-DNS-NAME>` with the actual DNS name of `portfolio-alb`.
- Do not expose private keys, database passwords, AWS credentials, tokens, or secrets in this repository.
- Do not hardcode AWS credentials in scripts or User Data.
- CPU stress testing should only be performed in controlled laboratory environments.
- Allow CloudWatch enough time to collect datapoints before evaluating Auto Scaling behavior.
- Allow the Target Tracking policy to perform scale-in automatically instead of manually modifying desired capacity.
- Security Group and network configuration should be validated before troubleshooting the application layer.

---

**Lab Status:** ✅ Completed
