# AWS IAM - Commands Reference

This document contains the commands, navigation paths, and actions performed during **Lab 01 - AWS Identity and Access Management (IAM)**.

---

# AWS Console Navigation

## Open IAM Service

AWS Console

→ Search "IAM"

→ Identity and Access Management (IAM)

---

# Create an IAM User

IAM

→ Users

→ Create user

Configuration:

| Property | Value |
|----------|-------|
| User name | henry.admin |
| Console access | Enabled |
| Password | Custom Password |

---

# Create an IAM Group

IAM

→ User groups

→ Create group

Configuration

| Property | Value |
|----------|-------|
| Group Name | Administrators |

---

# Attach AdministratorAccess Policy

IAM

→ User groups

→ Administrators

→ Permissions

→ Add permissions

→ Attach policies

Policy selected:

```
AdministratorAccess
```

---

# Add User to Group

IAM

→ Users

→ henry.admin

→ Add user to group

Selected group:

```
Administrators
```

---

# Configure MFA

IAM

→ Users

→ henry.admin

→ Security credentials

→ Assign MFA device

Configuration

| Property | Value |
|----------|-------|
| MFA Type | Authenticator App |
| Device | Virtual MFA |

---

# Login with IAM User

AWS Sign-in URL

```
https://<account-id>.signin.aws.amazon.com/console
```

User

```
henry.admin
```

Authentication

- Password
- MFA Code

---

# AWS CLI Commands

Check CLI Version

```bash
aws --version
```

Configure AWS CLI

```bash
aws configure
```

List IAM Users

```bash
aws iam list-users
```

List IAM Groups

```bash
aws iam list-groups
```

List Attached Policies

```bash
aws iam list-attached-group-policies \
--group-name Administrators
```

Get Current User

```bash
aws sts get-caller-identity
```

---

# Linux Commands

Current Directory

```bash
pwd
```

List Files

```bash
ls -la
```

Create Directory

```bash
mkdir directory-name
```

---

# PowerShell Commands

Current Directory

```powershell
pwd
```

List Files

```powershell
dir
```

Tree Structure

```powershell
tree /F
```

Git Status

```powershell
git status
```

---

# Git Commands

Check Repository Status

```bash
git status
```

Stage Changes

```bash
git add .
```

Commit Changes

```bash
git commit -m "Complete Lab 01 IAM documentation"
```

Push to GitHub

```bash
git push origin main
```

---

# Notes

Some AWS CLI commands require AWS CLI to be installed and configured using:

```bash
aws configure
```

This laboratory was primarily completed through the **AWS Management Console**.

AWS CLI commands are included for future automation and Infrastructure as Code (IaC) practices.
