# Amazon EC2 - Commands Reference

This document contains the AWS Console navigation paths, AWS CLI commands, Linux commands, PowerShell commands, Git commands, and troubleshooting commands used during **Lab 02 – Amazon Elastic Compute Cloud (EC2)**.

---

# AWS Console Navigation

## Launch EC2 Instance

AWS Console

→ EC2

→ Instances

→ Launch Instance

---

## Instance Configuration

| Property | Value |
|----------|-------|
| Name | Server-Lab01 |
| AMI | Ubuntu Server 24.04 LTS |
| Instance Type | t2.micro |
| Key Pair | henry-key.pem |
| Storage | 8 GB gp3 |

---

## Configure Security Group

Inbound Rules

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | My IP |

---

## Connect to Instance

AWS Console

→ EC2

→ Instances

→ Select Instance

→ Connect

→ SSH Client

---

# AWS CLI Commands

## Check AWS CLI Version

```bash
aws --version
```

---

## Configure AWS CLI

```bash
aws configure
```

---

## List EC2 Instances

```bash
aws ec2 describe-instances
```

---

## Start an Instance

```bash
aws ec2 start-instances \
--instance-ids i-xxxxxxxxxxxxxxxxx
```

---

## Stop an Instance

```bash
aws ec2 stop-instances \
--instance-ids i-xxxxxxxxxxxxxxxxx
```

---

## Reboot an Instance

```bash
aws ec2 reboot-instances \
--instance-ids i-xxxxxxxxxxxxxxxxx
```

---

## Terminate an Instance

```bash
aws ec2 terminate-instances \
--instance-ids i-xxxxxxxxxxxxxxxxx
```

---

## Describe Security Groups

```bash
aws ec2 describe-security-groups
```

---

## Describe Key Pairs

```bash
aws ec2 describe-key-pairs
```

---

# SSH Commands

## Change Private Key Permissions (Linux/macOS)

```bash
chmod 400 henry-key.pem
```

---

## Connect via SSH

```bash
ssh -i "henry-key.pem" \
ubuntu@ec2-public-ip
```

Example

```bash
ssh -i "henry-key.pem" \
ubuntu@ec2-3-145-109-160.us-east-2.compute.amazonaws.com
```

---

# Windows PowerShell Commands

## Current Directory

```powershell
pwd
```

---

## List Files

```powershell
dir
```

---

## Verify SSH Version

```powershell
ssh -V
```

---

## Connect to EC2

```powershell
ssh -i .\henry-key.pem ubuntu@ec2-public-dns
```

---

## Verbose SSH Connection

```powershell
ssh -vvv -i .\henry-key.pem ubuntu@ec2-public-dns
```

---

## View File Permissions

```powershell
icacls .\henry-key.pem
```

---

## Disable Inherited Permissions

```powershell
icacls .\henry-key.pem /inheritance:r
```

---

## Remove Built-in Users Permissions

```powershell
icacls .\henry-key.pem /remove "BUILTIN\Users"
```

---

# Linux Commands

## Current Directory

```bash
pwd
```

---

## List Files

```bash
ls -la
```

---

## Show Current User

```bash
whoami
```

---

## Operating System Information

```bash
cat /etc/os-release
```

---

## Kernel Version

```bash
uname -a
```

---

## Disk Usage

```bash
df -h
```

---

## Memory Information

```bash
free -h
```

---

## Uptime

```bash
uptime
```

---

# Git Commands

## Create Feature Branch

```bash
git checkout -b feature/lab-02-ec2
```

---

## Verify Branch

```bash
git branch
```

---

## Check Repository Status

```bash
git status
```

---

## Stage Changes

```bash
git add .
```

---

## Commit Changes

```bash
git commit -m "Complete Lab 02 EC2 documentation"
```

---

## Push Feature Branch

```bash
git push origin feature/lab-02-ec2
```

---

## Merge into Main

```bash
git checkout main
git merge feature/lab-02-ec2
git push origin main
```

---

# Notes

This laboratory was performed primarily through the **AWS Management Console**.

AWS CLI commands are included to introduce automation concepts and prepare for future Infrastructure as Code (IaC) laboratories using Terraform and CloudFormation.
