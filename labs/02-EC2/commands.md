# Commands – Amazon EC2 Laboratory

## Connect to the EC2 Instance

```powershell
ssh -i .\henry-key.pem ubuntu@PUBLIC_DNS
```

Example:

```powershell
ssh -i .\henry-key.pem ubuntu@ec2-example.compute.amazonaws.com
```

Do not publish the private key or use a real public address in documentation when it is unnecessary.

## Enable Detailed SSH Output

```powershell
ssh -vvv -i .\henry-key.pem ubuntu@PUBLIC_DNS
```

The `-vvv` option displays detailed diagnostic information about the SSH connection.

## Review Key Permissions in Windows

```powershell
icacls .\henry-key.pem
```

## Remove Inherited Permissions

```powershell
icacls .\henry-key.pem /inheritance:r
```

## Remove Access for Authenticated Users

```powershell
icacls .\henry-key.pem /remove "NT AUTHORITY\Authenticated Users"
```

## Remove Access for the Built-in Users Group

```powershell
icacls .\henry-key.pem /remove "BUILTIN\Usuarios"
```

The group name may appear as `BUILTIN\Users` on English Windows installations.

## Grant Read Permission to the Owner

```powershell
icacls .\henry-key.pem /grant "DESKTOP-MTQQR2P\PC:(R)"
```

Replace the computer and user name according to the local environment.

## Verify the Current Linux User

```bash
whoami
```

## Display the Hostname

```bash
hostname
```

## Display the Current Directory

```bash
pwd
```

## List Files and Directories

```bash
ls
```

## Display Operating-System Information

```bash
cat /etc/os-release
```

## Display CPU Information

```bash
lscpu
```

## Display Memory Usage

```bash
free -h
```

## Display Disk Usage

```bash
df -h
```

## Display IP Configuration

```bash
ip address
```

## Update Package Information

```bash
sudo apt update
```

## Install Available Package Updates

```bash
sudo apt upgrade -y
```

## Exit the SSH Session

```bash
exit
```

---

# `interview-questions.md`

# Interview Questions – Amazon EC2

## 1. What is Amazon EC2?

Amazon EC2 is an AWS compute service that provides resizable virtual servers in the cloud.

## 2. What is an AMI?

An AMI is a template containing the operating system, software and configuration required to launch an EC2 instance.

## 3. What is an EC2 instance type?

An instance type defines the amount of CPU, memory, networking capacity and other resources assigned to an EC2 instance.

## 4. What is the difference between stopping and terminating an EC2 instance?

Stopping powers off the instance while preserving its supported EBS volumes and configuration.

Terminating permanently deletes the instance and may also delete attached volumes configured for deletion.

## 5. What is a Security Group?

A Security Group is a stateful virtual firewall that controls inbound and outbound traffic for AWS resources.

## 6. Why is a Security Group considered stateful?

When inbound traffic is allowed, the response traffic is automatically allowed without requiring a separate outbound rule.

## 7. What is the purpose of an EC2 key pair?

A key pair is used to authenticate securely to a Linux EC2 instance using SSH.

## 8. What happens if the private key is lost?

The original private key cannot be downloaded again. Access must be restored through another method, such as Session Manager, EC2 Instance Connect, volume recovery or another authorized user.

## 9. What is the difference between a public IP and an Elastic IP?

A default public IP may change after the instance is stopped and started.

An Elastic IP is static and remains allocated until it is released.

## 10. What is Amazon EBS?

Amazon EBS provides persistent block storage volumes that can be attached to EC2 instances.

## 11. What is the difference between a Security Group and a Network ACL?

Security Groups are stateful and operate at the instance or network-interface level.

Network ACLs are stateless and operate at the subnet level.

## 12. Why should port 22 not be open to the entire Internet?

Allowing `0.0.0.0/0` increases the attack surface and exposes the SSH service to scanning and brute-force attempts.

## 13. What user is commonly used for Ubuntu EC2 instances?

The default user is usually:

```text
ubuntu
```

## 14. How can an EC2 instance access S3 securely?

The recommended approach is to attach an IAM role to the instance instead of storing permanent access keys on the server.

## 15. How can EC2 instances be monitored?

EC2 instances can be monitored using Amazon CloudWatch metrics, logs and alarms.
