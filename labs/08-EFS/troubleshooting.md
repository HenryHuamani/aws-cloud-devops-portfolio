# Lab 08 – Amazon Elastic File System (EFS)

## Troubleshooting Guide

This document describes the main troubleshooting scenarios encountered during the implementation and validation of Amazon EFS within the NovaCommerce AWS architecture.

The objective is to document not only the final solution, but also the diagnostic process used to identify the root cause of each issue.

---

# Troubleshooting Methodology

The troubleshooting process followed a layered approach:

```text
Client
  │
  ▼
Network Connectivity
  │
  ▼
Security Groups
  │
  ▼
EC2 Operating System
  │
  ▼
Application / Service
  │
  ▼
AWS Managed Service
```

Instead of changing multiple components simultaneously, each layer was validated independently.

---

# Issue 1 – SSH Connection Timeout

## Symptoms

An EC2 instance was running and had a public IPv4 address, but the SSH connection could not be established.

The connection timed out even though an SSH inbound rule had already been configured.

---

## Investigation

### Step 1 – Validate TCP Port 22 from the Client

From Windows PowerShell:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

This helped determine whether TCP port `22` was reachable from the client.

---

### Step 2 – Verify the SSH Service

Using an alternative administrative access method, the SSH daemon was checked:

```bash
sudo systemctl status sshd
```

The listening socket was also verified:

```bash
sudo ss -lntp | grep :22
```

This confirmed whether SSH was running and listening on the expected port.

---

### Step 3 – Inspect Incoming SSH Traffic

Packet inspection was used to determine whether SSH traffic was reaching the instance:

```bash
sudo tcpdump -nn -i any 'tcp port 22'
```

This was useful for separating an operating-system problem from a network or Security Group problem.

---

### Step 4 – Identify the Actual Client Source IP

After establishing a working SSH session, the following command was executed:

```bash
echo $SSH_CONNECTION
```

The output follows this format:

```text
<CLIENT_PUBLIC_IP> <CLIENT_PORT> <EC2_PRIVATE_IP> 22
```

The first value represents the source IP address observed by the EC2 instance.

---

## Root Cause

The public source IP actually used by the SSH connection was different from the address initially expected when configuring the Security Group.

Therefore, the Security Group rule did not initially represent the real client source address.

---

## Resolution

The actual source IP was identified and the SSH Security Group rule was corrected accordingly.

For administrative access, SSH should be restricted to the required source address instead of permanently allowing:

```text
0.0.0.0/0
```

---

## Validation

After correcting the rule, connectivity was tested again:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

and the SSH connection succeeded.

---

## Lesson Learned

Do not assume the public source IP used by a client connection.

The effective address can be influenced by:

- ISP routing.
- NAT.
- VPNs.
- Corporate networks.
- Proxies.
- Changes in the client's public address.

When troubleshooting, validate the address actually observed by the destination.

---

# Issue 2 – `amazon-efs-utils` Was Not Installed

## Symptoms

During EFS configuration, the EC2 instance did not have the Amazon EFS mount helper installed.

The required package was:

```text
amazon-efs-utils
```

Without it, commands using:

```bash
mount -t efs
```

cannot use the EFS mount helper as expected.

---

## Investigation

The package was checked with:

```bash
rpm -q amazon-efs-utils
```

If the package is missing, the command reports that it is not installed.

---

## Root Cause

The existing EC2 instance had been created before Amazon EFS was introduced into the architecture.

Therefore, the original instance configuration did not include the EFS utilities.

---

## Resolution

The package was installed using:

```bash
sudo dnf install -y amazon-efs-utils
```

The installation was then verified:

```bash
rpm -q amazon-efs-utils
```

---

## Architectural Correction

Installing the package manually solved the immediate problem, but manual configuration would not be sufficient for an Auto Scaling architecture.

The EC2 Launch Template User Data was therefore updated so that replacement instances automatically install:

```text
amazon-efs-utils
```

during bootstrap.

---

## Validation

A newly launched Auto Scaling instance was later checked using:

```bash
rpm -q amazon-efs-utils
```

The package was available without requiring manual installation.

---

## Lesson Learned

A manual correction on an existing EC2 instance is not enough when the infrastructure uses Auto Scaling.

The fix must be incorporated into the instance bootstrap process so that future instances receive the same configuration automatically.

---

# Validation Procedure – EFS Network Connectivity and Mounting

This section documents the validation process used for Amazon EFS.

It is not presented as a separate production incident because the objective was to verify the EFS configuration systematically.

---

## Step 1 – Verify Mount Targets

Amazon EFS requires network connectivity through Mount Targets.

The architecture was checked to confirm that Mount Targets were available for the Availability Zones used by the application.

Conceptually:

```text
EC2 – AZ-A
    │
    ▼
Mount Target A
    │
    ├─────────────┐
    │             │
    ▼             │
 Amazon EFS       │
    ▲             │
    │             │
    └─────────────┤
                  │
EC2 – AZ-B        │
    │             │
    ▼             │
Mount Target B ───┘
```

---

## Step 2 – Verify Security Group Rules

Amazon EFS uses NFS over:

```text
TCP 2049
```

The EFS Security Group must allow inbound NFS communication from the authorized application EC2 Security Group.

Expected configuration:

```text
Type: NFS
Protocol: TCP
Port: 2049
Source: Application EC2 Security Group
```

---

## Step 3 – Verify the Mount Directory

The mount point was created using:

```bash
sudo mkdir -p /mnt/efs
```

---

## Step 4 – Verify Persistent Configuration

The persistent EFS configuration was checked in:

```bash
cat /etc/fstab
```

The expected entry follows this structure:

```text
<EFS_ID>:/ /mnt/efs efs _netdev,tls 0 0
```

The options have important purposes:

```text
_netdev
```

indicates that the filesystem depends on network connectivity.

```text
tls
```

enables encryption in transit.

---

## Step 5 – Test the Configuration

Before rebooting, the configuration can be tested using:

```bash
sudo mount -a
```

The active mount can then be checked with:

```bash
df -hT | grep efs
```

Additional validation commands include:

```bash
mount | grep efs
```

and:

```bash
mountpoint /mnt/efs
```

---

## Step 6 – Validate Shared Content

The shared application directory was checked using:

```bash
ls -lah /mnt/efs/shared/
```

and:

```bash
cat /mnt/efs/shared/index.html
```

---

## Step 7 – Validate Apache Integration

The Apache symbolic link was checked using:

```bash
ls -lah /var/www/html/
```

Expected relationship:

```text
/var/www/html/shared -> /mnt/efs/shared
```

The shared application endpoint was then tested locally:

```bash
curl http://localhost/shared/
```

---

## Lesson Learned

EFS troubleshooting should be performed layer by layer:

```text
EFS File System
      │
      ▼
Mount Target
      │
      ▼
Security Group TCP/2049
      │
      ▼
amazon-efs-utils
      │
      ▼
/etc/fstab
      │
      ▼
EFS Mount
      │
      ▼
Shared Directory
      │
      ▼
Apache
```

This makes it easier to isolate the failing component.

---

# Issue 3 – Replacement Instances Must Mount EFS Automatically

## Context

The architecture uses an EC2 Auto Scaling Group.

Therefore, application instances can be:

- Replaced.
- Terminated.
- Recreated.
- Scaled horizontally.

Manually configuring EFS on an existing instance would not guarantee that future instances receive the same configuration.

---

## Risk

Without automated bootstrap configuration:

```text
Existing EC2
EFS configured
      │
      ▼
Instance replaced
      │
      ▼
New EC2
EFS not configured
```

This would introduce configuration drift.

---

## Resolution

The EC2 Launch Template User Data was updated to automate the EFS configuration.

The bootstrap process performs tasks such as:

```text
Install Apache
      │
      ▼
Install amazon-efs-utils
      │
      ▼
Create /mnt/efs
      │
      ▼
Configure /etc/fstab
      │
      ▼
Mount Amazon EFS
      │
      ▼
Create /mnt/efs/shared
      │
      ▼
Create Apache symbolic link
```

---

## Validation

After launching a new instance through the Auto Scaling Group, the following checks were performed:

```bash
rpm -q amazon-efs-utils
```

```bash
df -hT | grep efs
```

```bash
grep efs /etc/fstab
```

```bash
ls -lah /var/www/html/
```

```bash
cat /mnt/efs/shared/index.html
```

```bash
curl http://localhost/shared/
```

The replacement instance successfully accessed the existing EFS content without requiring manual EFS configuration.

---

## Lesson Learned

For Auto Scaling workloads:

> Fix the template, not only the instance.

Infrastructure configuration must be reproducible so that replacement instances can automatically reach the desired state.

---

# Issue 4 – Intermittent `Not Found` through the Application Load Balancer

## Symptoms

The shared application page worked correctly when tested directly on an updated EC2 instance:

```bash
curl http://localhost/shared/
```

However, requests through the Application Load Balancer sometimes returned:

```text
Not Found
```

The behavior appeared inconsistent because the page worked on some requests but failed on others.

---

## Investigation

### Step 1 – Validate the Application Locally

The shared endpoint was tested directly from the EC2 instance:

```bash
curl http://localhost/shared/
```

The page was returned correctly.

This indicated that:

- Apache was running.
- The symbolic link worked.
- EFS was mounted.
- The shared file existed.

Therefore, the problem was no longer isolated to EFS or Apache.

---

### Step 2 – Inspect the Target Group

The Application Load Balancer Target Group was reviewed.

Multiple EC2 targets were registered.

Some targets belonged to an older application configuration and did not contain the new EFS `/shared/` integration.

---

### Step 3 – Understand the Inconsistent Behavior

The ALB could distribute requests to different registered targets.

Conceptually:

```text
                    ALB
                     │
             ┌───────┴───────┐
             │               │
             ▼               ▼
      Updated EC2        Old EC2
             │               │
             ▼               ▼
      /shared/ works     /shared/ missing
             │               │
             ▼               ▼
          200 OK          Not Found
```

This explained why repeated browser requests could produce different results.

---

## Why Were the Old Targets Still Healthy?

The Target Group health check validates only the configured health-check path.

For example:

```text
Health-check path
/
```

could return:

```text
200 OK
```

even if:

```text
/shared/
```

did not exist on that target.

Therefore:

```text
Healthy Target ≠ Every Application Endpoint Works
```

This was an important troubleshooting finding during the laboratory.

---

## Root Cause

Obsolete EC2 instances remained registered in the Target Group.

Those instances were healthy according to the configured health check but did not contain the current EFS-backed `/shared/` application configuration.

---

## Resolution

The obsolete targets were deregistered from the Target Group.

The final Target Group was left with the current application instances managed by the updated architecture.

---

## Validation

After deregistration, the Target Group was checked again.

Final state:

```text
2 Total Targets
2 Healthy
0 Unhealthy
```

The shared application page was then tested through the Application Load Balancer:

```text
http://<ALB_DNS_NAME>/shared/
```

The page loaded correctly.

---

## Lesson Learned

Load-balancer troubleshooting must include all registered targets.

Testing only one EC2 instance can produce a false sense of correctness.

A useful troubleshooting sequence is:

```text
Application fails through ALB
           │
           ▼
Test localhost on EC2
           │
           ├── Fails
           │     ▼
           │  Investigate application / EFS
           │
           └── Works
                 ▼
          Inspect Target Group
                 │
                 ▼
          Test every target
                 │
                 ▼
          Review listener/routing
```

---

# Issue 5 – SSH Source Address Should Not Be Assumed

## Context

During SSH troubleshooting, temporarily broadening the inbound rule helped determine whether the Security Group source restriction was involved.

However, this should only be a diagnostic step.

---

## Unsafe Permanent Configuration

The following rule should not be retained permanently:

```text
SSH
TCP 22
0.0.0.0/0
```

It unnecessarily exposes SSH to the Internet.

---

## Preferred Configuration

Restrict SSH to the required source:

```text
SSH
TCP 22
<TRUSTED_CLIENT_PUBLIC_IP>/32
```

For production environments, direct Internet-facing SSH can be avoided entirely by using controlled administrative access mechanisms such as AWS Systems Manager Session Manager when the architecture and IAM configuration support it.

---

## Lesson Learned

Temporary troubleshooting rules must be reverted after diagnosis.

A successful test with a broad rule identifies the problem domain; it is not the final security configuration.

---

# Useful Diagnostic Commands

## SSH

```bash
sudo systemctl status sshd
```

```bash
sudo ss -lntp | grep :22
```

```bash
echo $SSH_CONNECTION
```

```bash
sudo tcpdump -nn -i any 'tcp port 22'
```

Windows:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

---

## EFS Package

```bash
rpm -q amazon-efs-utils
```

---

## EFS Mount

```bash
df -hT | grep efs
```

```bash
mount | grep efs
```

```bash
mountpoint /mnt/efs
```

---

## Persistent Mount

```bash
grep efs /etc/fstab
```

```bash
sudo mount -a
```

---

## Shared Content

```bash
ls -lah /mnt/efs/shared/
```

```bash
cat /mnt/efs/shared/index.html
```

---

## Apache

```bash
sudo systemctl status httpd
```

```bash
ls -lah /var/www/html/
```

```bash
curl http://localhost/
```

```bash
curl http://localhost/shared/
```

---

# Troubleshooting Decision Tree

```text
EFS-backed page unavailable
          │
          ▼
Is EFS mounted?
          │
     ┌────┴────┐
     │         │
    NO        YES
     │         │
     ▼         ▼
Check        Check
package      shared file
2049 SG         │
Mount Target    ▼
fstab        File exists?
DNS             │
             ┌──┴──┐
             │     │
            NO    YES
             │     │
             ▼     ▼
          Check   Check
          EFS     Apache
          data    symlink
                    │
                    ▼
             localhost works?
                    │
               ┌────┴────┐
               │         │
              NO        YES
               │         │
               ▼         ▼
            Apache     Inspect
            config     ALB/TG
                          │
                          ▼
                    Test every
                    registered
                      target
```

---

# Root Cause Summary

| Problem | Root Cause | Resolution |
|---|---|---|
| SSH timeout | Security Group source did not match the actual client source address | Identify actual source IP and correct SSH rule |
| EFS mount helper unavailable | `amazon-efs-utils` was not installed on the existing instance | Install package and add installation to Launch Template bootstrap |
| Replacement instance configuration | Manual configuration would not survive EC2 replacement | Automate EFS setup through Launch Template User Data |
| Intermittent ALB `Not Found` | Obsolete EC2 targets remained registered | Deregister obsolete targets and validate current targets |
| Broad SSH access during testing | Temporary diagnostic rule was too permissive for permanent use | Restore least-privilege SSH access |

---

# Key Lessons Learned

## 1. Troubleshoot Layer by Layer

Do not modify multiple components simultaneously.

Validate:

```text
Network
  ↓
Security
  ↓
Operating System
  ↓
Filesystem
  ↓
Application
  ↓
Load Balancer
```

---

## 2. Validate the Actual Network Source

The address expected by the administrator is not necessarily the address observed by EC2.

Use evidence from the destination whenever possible.

---

## 3. Auto Scaling Requires Automation

A manually configured EC2 instance is not a reliable architecture.

Replacement instances must configure themselves automatically.

---

## 4. Shared State Should Not Depend on EC2

EC2 instances are replaceable.

Persistent shared files belong in a persistent storage service such as Amazon EFS when shared filesystem semantics are required.

---

## 5. Health Checks Have Limited Scope

A healthy ALB target only proves that the configured health-check endpoint satisfies the health-check criteria.

It does not prove that every application route is working.

---

## 6. Test the Complete Request Path

The final validation should follow the same path used by the application user:

```text
Browser
   │
   ▼
Application Load Balancer
   │
   ▼
Target Group
   │
   ▼
EC2
   │
   ▼
Apache
   │
   ▼
Amazon EFS
```

---

# Final Troubleshooting Outcome

The troubleshooting performed during Lab 08 validated not only the Amazon EFS implementation but also the interaction between:

```text
Client Network
      +
Security Groups
      +
Amazon EC2
      +
Launch Templates
      +
Auto Scaling
      +
Amazon EFS
      +
Apache
      +
Target Groups
      +
Application Load Balancer
```

The final architecture successfully demonstrated:

```text
Replaceable EC2 Compute
          +
Automated Configuration
          +
Persistent Shared Storage
          +
Load-Balanced Application Access
```