# Lab 08 – Amazon Elastic File System (EFS)

## Commands Reference

This document contains the main Linux, Amazon EFS, Apache, networking, and validation commands used during Lab 08.

The commands cover the complete workflow used to integrate Amazon EFS with EC2 instances managed by an Auto Scaling Group.

---

## 1. Environment Information

Verify the current user:

```bash
whoami
```

Verify the hostname:

```bash
hostname
```

Verify the operating system:

```bash
cat /etc/os-release
```

Display the private IP configuration:

```bash
ip addr
```

---

## 2. Connect to an EC2 Instance

Connect using SSH:

```bash
ssh -i "henry-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

Alternatively, connect using:

```text
AWS Console
→ EC2
→ Instances
→ Select instance
→ Connect
→ Session Manager
→ Connect
```

AWS Systems Manager Session Manager was particularly useful during this laboratory for validating instances without depending on direct SSH connectivity.

---

## 3. Verify Amazon EFS Utilities

Check whether `amazon-efs-utils` is installed:

```bash
rpm -q amazon-efs-utils
```

If the package is not installed:

```bash
sudo dnf install -y amazon-efs-utils
```

Verify the installation:

```bash
rpm -q amazon-efs-utils
```

Example expected result:

```text
amazon-efs-utils-3.1.3-1.amzn2023.x86_64
```

---

## 4. Create the Amazon EFS Mount Point

Create the mount directory:

```bash
sudo mkdir -p /mnt/efs
```

Verify the directory:

```bash
ls -ld /mnt/efs
```

---

## 5. Mount Amazon EFS

Amazon EFS file system used in this laboratory:

```text
fs-04a66a073c14f5d1c
```

Mount Amazon EFS using TLS:

```bash
sudo mount -t efs -o tls fs-04a66a073c14f5d1c:/ /mnt/efs
```

---

## 6. Verify the EFS Mount

Verify the mounted file system:

```bash
df -hT | grep efs
```

Verify the active mount:

```bash
mount | grep efs
```

Verify the mount point:

```bash
mountpoint /mnt/efs
```

A successful configuration should confirm that Amazon EFS is mounted at:

```text
/mnt/efs
```

---

## 7. Configure Persistent EFS Mounting

To ensure that Amazon EFS is automatically mounted after an EC2 reboot, add the following entry to `/etc/fstab`:

```bash
if ! grep -q "fs-04a66a073c14f5d1c" /etc/fstab; then
    echo "fs-04a66a073c14f5d1c:/ /mnt/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
fi
```

Verify the configuration:

```bash
grep efs /etc/fstab
```

Expected configuration:

```text
fs-04a66a073c14f5d1c:/ /mnt/efs efs _netdev,tls 0 0
```

Test the `/etc/fstab` configuration:

```bash
sudo mount -a
```

Verify again:

```bash
df -hT | grep efs
```

---

## 8. Validate Shared Storage

Create a test file from one EC2 instance:

```bash
echo "NovaCommerce shared storage - Lab 08 EFS" | sudo tee /mnt/efs/novacommerce-test.txt
```

Verify the file:

```bash
cat /mnt/efs/novacommerce-test.txt
```

Expected result:

```text
NovaCommerce shared storage - Lab 08 EFS
```

List the contents of the EFS file system:

```bash
ls -lah /mnt/efs
```

---

## 9. Validate Shared Storage from Another EC2 Instance

Connect to another EC2 instance that mounts the same Amazon EFS file system.

Verify the mount:

```bash
df -hT | grep efs
```

Read the file created by the first instance:

```bash
cat /mnt/efs/novacommerce-test.txt
```

Expected result:

```text
NovaCommerce shared storage - Lab 08 EFS
```

This confirms that multiple EC2 instances can access the same shared file system.

---

## 10. Create the Shared Application Directory

Create the shared directory inside Amazon EFS:

```bash
sudo mkdir -p /mnt/efs/shared
```

Verify:

```bash
ls -lah /mnt/efs
```

---

## 11. Create Shared Web Content

Create the shared application page:

```bash
sudo tee /mnt/efs/shared/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>NovaCommerce - Amazon EFS</title>
</head>

<body>

    <h1>NovaCommerce Shared Storage</h1>

    <h2>Amazon EFS - Lab 08</h2>

    <p>This content is stored in Amazon EFS.</p>

    <p>Multiple EC2 instances can access the same shared file system.</p>

</body>

</html>
EOF
```

Verify the file:

```bash
cat /mnt/efs/shared/index.html
```

---

## 12. Configure Apache to Serve EFS Content

Verify the Apache document root:

```bash
ls -lah /var/www/html/
```

Create a symbolic link between the Apache document root and the shared EFS directory:

```bash
sudo rm -rf /var/www/html/shared
sudo ln -s /mnt/efs/shared /var/www/html/shared
```

Verify the symbolic link:

```bash
ls -lah /var/www/html/
```

Expected result:

```text
shared -> /mnt/efs/shared
```

The resulting path is:

```text
/var/www/html/shared
        │
        └──> /mnt/efs/shared
                  │
                  └──> Amazon EFS
```

---

## 13. Validate Apache

Verify Apache status:

```bash
sudo systemctl status httpd
```

Check whether Apache is active:

```bash
systemctl is-active httpd
```

Restart Apache if required:

```bash
sudo systemctl restart httpd
```

Enable Apache at system startup:

```bash
sudo systemctl enable httpd
```

---

## 14. Validate Shared Content Locally

Test the shared application path:

```bash
curl http://localhost/shared/
```

Expected content:

```text
NovaCommerce Shared Storage
Amazon EFS - Lab 08
```

This confirms that Apache can access content stored in Amazon EFS.

---

## 15. Validate EFS After an EC2 Reboot

Restart the EC2 instance:

```bash
sudo reboot
```

Reconnect after the instance becomes available.

Verify that EFS was automatically mounted:

```bash
df -hT | grep efs
```

Verify the active mount:

```bash
mount | grep /mnt/efs
```

Verify `/etc/fstab`:

```bash
grep efs /etc/fstab
```

Verify that the original shared test file still exists:

```bash
cat /mnt/efs/novacommerce-test.txt
```

Expected result:

```text
NovaCommerce shared storage - Lab 08 EFS
```

This validates persistent mounting after an EC2 reboot.

---

## 16. Validate the Launch Template Bootstrap

After updating the EC2 Launch Template, newly launched instances should automatically configure Amazon EFS.

On a new EC2 instance, do not manually install or mount anything.

Verify the hostname:

```bash
hostname
```

Verify that EFS utilities were automatically installed:

```bash
rpm -q amazon-efs-utils
```

Verify that EFS was automatically mounted:

```bash
df -hT | grep efs
```

Verify the persistent mount configuration:

```bash
grep efs /etc/fstab
```

Verify the Apache symbolic link:

```bash
ls -lah /var/www/html/
```

Expected result:

```text
shared -> /mnt/efs/shared
```

---

## 17. Validate Persistent Data on a Replacement Instance

Verify that the replacement instance can access the file created before the instance replacement:

```bash
cat /mnt/efs/novacommerce-test.txt
```

Verify the shared application page:

```bash
cat /mnt/efs/shared/index.html
```

Test Apache:

```bash
curl http://localhost/shared/
```

Expected result:

```text
NovaCommerce Shared Storage
Amazon EFS - Lab 08
```

This confirms that the application data is independent of the lifecycle of an individual EC2 instance.

---

## 18. Final Replacement Instance Validation

The following command sequence was used as the final validation on the new Auto Scaling instance:

```bash
hostname

rpm -q amazon-efs-utils

df -hT | grep efs

grep efs /etc/fstab

ls -lah /var/www/html/

cat /mnt/efs/shared/index.html

curl http://localhost/shared/
```

The validation confirms:

```text
amazon-efs-utils          → Installed
Amazon EFS                → Mounted
/etc/fstab                → Configured
/mnt/efs                  → Available
/mnt/efs/shared           → Available
/var/www/html/shared      → Symbolic link created
Shared index.html         → Persistent
Apache /shared/           → Working
```

---

# Troubleshooting Commands

## 19. SSH Connectivity Test from Windows

Test whether TCP port 22 is reachable:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

Example:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

Review:

```text
TcpTestSucceeded
```

---

## 20. Verbose SSH Connection

Use verbose SSH output for troubleshooting:

```powershell
ssh -vvv -i "henry-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

This provides additional information about:

- TCP connectivity.
- SSH negotiation.
- Authentication.
- Key exchange.
- Connection timeout.

---

## 21. Verify the SSH Service

Using AWS Systems Manager Session Manager:

```bash
sudo systemctl status sshd --no-pager
```

Verify that SSH is listening on TCP port 22:

```bash
sudo ss -lntp | grep :22
```

Restart SSH if required:

```bash
sudo systemctl restart sshd
```

---

## 22. Capture SSH Traffic

Use `tcpdump` to determine whether SSH packets are reaching the EC2 instance:

```bash
sudo tcpdump -nn -i any 'tcp port 22'
```

This command was useful for comparing the expected client IP with the actual source IP observed by the EC2 instance.

---

## 23. Identify the Actual SSH Source IP

Inside an active SSH connection:

```bash
echo $SSH_CONNECTION
```

Example result:

```text
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

The fields represent:

```text
<Client IP> <Client Port> <Server Private IP> <Server Port>
```

Therefore:

```text
EC2_PUBLIC_IP
```

is the public source IP observed by the EC2 instance.

This information can be used to configure the EC2 Security Group SSH rule correctly.

---

## 24. Verify Logged-In Users

Display active sessions:

```bash
who
```

Review previous login activity:

```bash
last -i
```

---

## 25. Verify Network Interfaces

```bash
ip addr
```

Alternative:

```bash
ip a
```

---

## 26. Verify Routing

```bash
ip route
```

This can be used to verify the default route configured on the EC2 instance.

---

## 27. Verify DNS Resolution

Resolve a hostname:

```bash
getent hosts <HOSTNAME>
```

Example:

```bash
getent hosts amazon.com
```

---

# EFS Troubleshooting

## 28. Verify the EFS Mount Point

```bash
mountpoint /mnt/efs
```

Or:

```bash
mountpoint -q /mnt/efs
```

Check the exit status:

```bash
echo $?
```

A result of:

```text
0
```

indicates that the path is a valid mount point.

---

## 29. Verify EFS in `/etc/fstab`

```bash
grep fs-04a66a073c14f5d1c /etc/fstab
```

Expected:

```text
fs-04a66a073c14f5d1c:/ /mnt/efs efs _netdev,tls 0 0
```

---

## 30. Test All `/etc/fstab` Mounts

```bash
sudo mount -a
```

Then verify:

```bash
df -hT | grep efs
```

---

## 31. Verify the Shared Directory

```bash
ls -lah /mnt/efs/shared/
```

Verify the shared application file:

```bash
cat /mnt/efs/shared/index.html
```

---

## 32. Verify the Apache Symbolic Link

```bash
ls -lah /var/www/html/
```

Verify only the shared path:

```bash
ls -ld /var/www/html/shared
```

Expected:

```text
/var/www/html/shared -> /mnt/efs/shared
```

---

## 33. Verify the Symbolic Link Programmatically

```bash
test -L /var/www/html/shared
```

Check the result:

```bash
echo $?
```

Expected:

```text
0
```

---

## 34. Test Apache Locally

Test the root application:

```bash
curl http://localhost/
```

Test the EFS shared application:

```bash
curl http://localhost/shared/
```

---

# Application Load Balancer Validation

## 35. Validate Shared Content through the ALB

From a browser:

```text
http://<ALB-DNS-NAME>/shared/
```

For this laboratory:

```text
http://portfolio-alb-533304341.us-east-2.elb.amazonaws.com/shared/
```

Expected page:

```text
NovaCommerce Shared Storage

Amazon EFS - Lab 08

This content is stored in Amazon EFS.

Multiple EC2 instances can access the same shared file system.
```

---

## 36. Validate the ALB from the Command Line

```bash
curl http://<ALB-DNS-NAME>/shared/
```

Example:

```bash
curl http://portfolio-alb-533304341.us-east-2.elb.amazonaws.com/shared/
```

---

# Auto Scaling Validation

## 37. Validate a Newly Launched Instance

After Auto Scaling launches a replacement EC2 instance:

```bash
hostname
```

```bash
rpm -q amazon-efs-utils
```

```bash
mountpoint -q /mnt/efs
```

```bash
grep fs-04a66a073c14f5d1c /etc/fstab
```

```bash
test -L /var/www/html/shared
```

```bash
cat /mnt/efs/shared/index.html
```

```bash
curl http://localhost/shared/
```

No manual installation, mount operation, or symbolic-link creation should be required on the replacement instance.

---

# Important Configuration Values

## Amazon EFS

```text
File System Name : novacommerce-efs
File System ID   : fs-04a66a073c14f5d1c
Mount Point      : /mnt/efs
Shared Directory : /mnt/efs/shared
```

## Apache

```text
Document Root : /var/www/html
Shared Path   : /var/www/html/shared
```

## Launch Template

```text
Launch Template : portfolio-web-template
Version         : 5
```

## Auto Scaling

```text
Auto Scaling Group : portfolio-asg
Desired Capacity   : 2
Minimum Capacity   : 2
Maximum Capacity   : 4
```

## Load Balancing

```text
Application Load Balancer : portfolio-alb
Target Group              : portfolio-web-tg
```

---

# Important Ports

| Service | Protocol | Port | Purpose |
|---------|----------|-----:|---------|
| HTTP | TCP | 80 | Web application traffic |
| SSH | TCP | 22 | Remote administration |
| NFS | TCP | 2049 | Amazon EFS communication |
| MySQL | TCP | 3306 | Amazon RDS database communication |

---

# Important File System Paths

| Path | Purpose |
|------|---------|
| `/mnt/efs` | Amazon EFS mount point |
| `/mnt/efs/shared` | Persistent shared web content |
| `/mnt/efs/novacommerce-test.txt` | Shared storage validation file |
| `/var/www/html` | Apache document root |
| `/var/www/html/index.html` | Local EC2 landing page |
| `/var/www/html/shared` | Symbolic link to EFS shared content |
| `/etc/fstab` | Persistent file system mount configuration |

---

# Quick EFS Health Check

Use the following commands for a quick validation:

```bash
rpm -q amazon-efs-utils
df -hT | grep efs
grep efs /etc/fstab
mountpoint /mnt/efs
ls -lah /mnt/efs
ls -lah /var/www/html/
curl http://localhost/shared/
```

---

# Final Lab Validation

The following sequence provides a complete validation of the EC2 and EFS integration:

```bash
echo "===== INSTANCE ====="
hostname

echo "===== EFS UTILITIES ====="
rpm -q amazon-efs-utils

echo "===== EFS MOUNT ====="
df -hT | grep efs

echo "===== FSTAB ====="
grep efs /etc/fstab

echo "===== SHARED STORAGE ====="
ls -lah /mnt/efs/shared/

echo "===== APACHE LINK ====="
ls -lah /var/www/html/

echo "===== PERSISTENT CONTENT ====="
cat /mnt/efs/shared/index.html

echo "===== LOCAL HTTP TEST ====="
curl http://localhost/shared/
```

A successful result confirms the complete path:

```text
EC2
 │
 ├── amazon-efs-utils
 │
 ├── /etc/fstab
 │
 ├── /mnt/efs
 │      │
 │      └── shared/index.html
 │
 └── /var/www/html/shared
             │
             └──> /mnt/efs/shared
                        │
                        ▼
                    Amazon EFS
```

---

# Result

The commands in this document were used to validate that Amazon EFS provides shared and persistent storage for the NovaCommerce EC2 application tier.

The final implementation confirms that replacement EC2 instances launched by the Auto Scaling Group can automatically mount the existing EFS file system and access the same shared application content without manual reconfiguration.