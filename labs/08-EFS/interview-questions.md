# Lab 08 – Amazon Elastic File System (EFS)

## Interview Questions

This document contains technical and scenario-based interview questions related to the concepts implemented in Lab 08.

The questions are organized by level:

- Junior
- Mid-Level
- Senior
- Solutions Architect

The objective is to review Amazon EFS fundamentals, EC2 integration, networking, security, Auto Scaling, Application Load Balancing, automation, and troubleshooting.

---

# Junior

## 1. What is Amazon EFS?

Amazon Elastic File System (Amazon EFS) is a managed file storage service that provides shared filesystem access for AWS compute resources.

Multiple EC2 instances can mount and access the same EFS file system simultaneously.

---

## 2. What type of storage does Amazon EFS provide?

Amazon EFS provides file storage.

It is different from:

- Amazon EBS → Block storage
- Amazon EFS → File storage
- Amazon S3 → Object storage

---

## 3. Which protocol does Amazon EFS use?

Amazon EFS uses the Network File System protocol.

```text
Protocol: NFS
Transport: TCP
Port: 2049
```

---

## 4. Can multiple EC2 instances access the same EFS file system?

Yes.

Multiple EC2 instances can mount the same Amazon EFS file system and access shared files simultaneously.

Example:

```text
EC2-A ─────┐
           │
           ▼
       Amazon EFS
           ▲
           │
EC2-B ─────┘
```

---

## 5. Why was Amazon EFS used in Lab 08?

Amazon EFS was used to provide persistent shared storage for EC2 instances managed by an Auto Scaling Group.

This allows replacement EC2 instances to access the same application files.

---

## 6. What is the default NFS port used by Amazon EFS?

```text
TCP 2049
```

---

## 7. What package was installed on the EC2 instances to mount Amazon EFS?

```text
amazon-efs-utils
```

The package can be installed on Amazon Linux using:

```bash
sudo dnf install -y amazon-efs-utils
```

---

## 8. Where was Amazon EFS mounted in Lab 08?

Amazon EFS was mounted at:

```text
/mnt/efs
```

---

## 9. Where was the shared web content stored?

The shared application content was stored at:

```text
/mnt/efs/shared
```

---

## 10. How was the shared EFS content exposed through Apache?

A symbolic link was created:

```text
/var/www/html/shared
        │
        ▼
/mnt/efs/shared
```

This allowed Apache to serve content stored in Amazon EFS.

---

## 11. Which command can be used to verify that EFS is mounted?

```bash
df -hT | grep efs
```

Other useful commands include:

```bash
mount | grep efs
```

and:

```bash
mountpoint /mnt/efs
```

---

## 12. What is `/etc/fstab` used for?

`/etc/fstab` defines filesystems that should be mounted automatically.

In Lab 08, it was used to ensure that Amazon EFS was mounted again after an EC2 reboot.

---

## 13. What does `_netdev` mean in `/etc/fstab`?

`_netdev` indicates that the filesystem depends on network connectivity.

This is important because Amazon EFS is a network filesystem.

---

## 14. How was encryption in transit enabled?

Amazon EFS was mounted using TLS.

Example:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

---

## 15. What is an EFS Mount Target?

An EFS Mount Target provides network connectivity between resources in a VPC and an Amazon EFS file system.

EC2 instances connect to EFS through Mount Targets.

---

# Mid-Level

## 16. What is the difference between Amazon EFS and Amazon EBS?

Amazon EBS provides block storage primarily for EC2 instances.

Amazon EFS provides shared file storage that can be accessed by multiple EC2 instances.

Simplified:

```text
EBS

EC2
 │
 ▼
EBS Volume
```

```text
EFS

EC2-A ─┐
       │
       ▼
      EFS
       ▲
       │
EC2-B ─┘
```

---

## 17. What is the difference between Amazon EFS and Amazon S3?

Amazon EFS provides traditional filesystem semantics using NFS.

Amazon S3 provides object storage accessed primarily through APIs.

EFS is appropriate when applications require shared filesystem access.

S3 is appropriate when applications can store and retrieve data as objects.

---

## 18. Why is EFS useful with an Auto Scaling Group?

Auto Scaling instances can be created, terminated, or replaced at any time.

Amazon EFS allows persistent application files to exist independently of those EC2 instances.

This means:

```text
EC2 terminated
      │
      ▼
Shared files remain in EFS
      │
      ▼
New EC2 launched
      │
      ▼
New EC2 mounts existing EFS
```

---

## 19. Why should EFS access be controlled with Security Groups?

Security Groups restrict which resources can communicate with EFS Mount Targets.

For this architecture, the EFS Security Group should allow:

```text
Type: NFS
Protocol: TCP
Port: 2049
Source: Application EC2 Security Group
```

This prevents unnecessary network access to the filesystem.

---

## 20. Why is using a Security Group reference better than allowing `0.0.0.0/0`?

A Security Group reference allows access only from authorized AWS resources associated with the specified Security Group.

This follows the principle of least privilege and avoids exposing NFS publicly.

---

## 21. Why were Mount Targets created across multiple Availability Zones?

The application EC2 instances operate across multiple Availability Zones.

Mount Targets provide local network access to the Regional EFS file system from those Availability Zones.

Conceptually:

```text
AZ-A
 │
 ├── EC2
 └── EFS Mount Target

AZ-B
 │
 ├── EC2
 └── EFS Mount Target
```

---

## 22. How was EFS mounting automated for replacement instances?

The EC2 Launch Template User Data was updated to automatically:

- Install Apache.
- Install `amazon-efs-utils`.
- Create `/mnt/efs`.
- Configure `/etc/fstab`.
- Mount Amazon EFS.
- Create the shared directory.
- Create the Apache symbolic link.

---

## 23. Why should this configuration be automated?

Manual configuration would cause configuration drift.

For example:

```text
EC2-A
EFS mounted ✅

EC2-B
EFS not mounted ❌
```

Automation ensures that replacement instances receive consistent configuration.

---

## 24. What is configuration drift?

Configuration drift occurs when infrastructure components that should have the same configuration become different over time.

Launch Templates and automated bootstrap scripts help reduce this problem.

---

## 25. Why was a new Launch Template version created?

Launch Template versioning allows infrastructure changes to be tracked without overwriting previous configurations.

Benefits include:

- Change history.
- Controlled updates.
- Reproducibility.
- Rollback capability.

---

## 26. How can you validate that a replacement EC2 instance mounted EFS automatically?

Useful commands include:

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

---

## 27. Why was a symbolic link used instead of moving the entire Apache document root to EFS?

The existing local Apache page contained EC2-specific information.

The symbolic link allowed the architecture to maintain:

```text
Local content:
/var/www/html/index.html
```

while exposing:

```text
Shared content:
/var/www/html/shared
        ↓
/mnt/efs/shared
```

This demonstrates the difference between local and shared application state.

---

## 28. What happens to files stored in EFS when an EC2 instance is terminated?

The files remain in Amazon EFS because EFS storage is independent of the EC2 instance lifecycle.

---

## 29. How did you validate shared storage between instances?

A test file was created in the EFS mount from one EC2 instance.

Example:

```bash
echo "NovaCommerce shared storage - Lab 08 EFS" | sudo tee /mnt/efs/novacommerce-test.txt
```

The same file was then read from another instance:

```bash
cat /mnt/efs/novacommerce-test.txt
```

This confirmed shared filesystem access.

---

## 30. How did you validate EFS persistence after reboot?

The instance was rebooted after configuring `/etc/fstab`.

After reconnecting:

```bash
df -hT | grep efs
```

was used to verify that EFS had mounted automatically.

The existing test file was then read again.

---

# Senior

## 31. How would you troubleshoot an EC2 instance that cannot mount Amazon EFS?

I would validate the problem layer by layer.

First:

```bash
rpm -q amazon-efs-utils
```

Then verify:

- EFS File System ID.
- Mount point.
- `/etc/fstab`.
- EFS Mount Targets.
- Security Groups.
- TCP port 2049.
- VPC connectivity.
- DNS resolution.

I would then attempt the mount and inspect the resulting error.

---

## 32. An EFS mount works manually but fails after reboot. What would you investigate?

I would inspect:

```bash
cat /etc/fstab
```

and verify:

- Correct EFS File System ID.
- Correct mount directory.
- `efs` filesystem type.
- `_netdev`.
- `tls`.
- Network availability during startup.

I would also test:

```bash
sudo mount -a
```

before rebooting.

---

## 33. The application works locally on an EC2 instance but intermittently returns 404 through the ALB. What would you investigate?

I would first confirm local behavior:

```bash
curl http://localhost/shared/
```

If that works, I would inspect:

- Target Group membership.
- Every registered EC2 target.
- Application configuration on each target.
- Target Group health-check path.
- Listener rules.
- Configuration drift.

---

## 34. What caused the intermittent `Not Found` issue in Lab 08?

Older EC2 instances remained registered in the Target Group.

Those instances were healthy according to the configured health check but did not contain the current `/shared/` configuration.

The ALB could therefore send a request to either:

```text
Updated target → /shared/ works
```

or:

```text
Old target → /shared/ returns Not Found
```

---

## 35. Why can a target be Healthy while `/shared/` returns 404?

The Target Group evaluates only its configured health-check path.

For example:

```text
Health check:
/

Result:
200 OK
```

does not guarantee:

```text
/shared/
```

also exists.

Therefore:

```text
Healthy target ≠ Every application endpoint is healthy
```

---

## 36. How was the ALB problem resolved?

The obsolete EC2 targets were deregistered from the Target Group.

After cleanup, only the current application instances remained registered.

The `/shared/` path was then tested again through the ALB.

---

## 37. How would you investigate an SSH timeout to an EC2 instance?

I would validate:

1. Instance state.
2. Public IPv4 address.
3. Security Group.
4. Route Table.
5. Internet Gateway.
6. Network ACL.
7. SSH daemon.
8. TCP port 22.
9. Actual client source IP.

From Windows:

```powershell
Test-NetConnection <EC2_PUBLIC_IP> -Port 22
```

On EC2:

```bash
sudo systemctl status sshd
```

```bash
sudo ss -lntp | grep :22
```

---

## 38. How did you identify the actual SSH source IP in the laboratory?

The command:

```bash
echo $SSH_CONNECTION
```

was used.

Example:

```text
190.43.252.54 60105 10.0.1.133 22
```

The first value represents the client IP observed by the EC2 instance.

---

## 39. Why can the source IP observed by EC2 differ from the IP you initially expect?

The outbound path can be affected by the client network, ISP, NAT, VPN, proxy, or other network infrastructure.

Therefore, the actual source address should be validated instead of assumed.

---

## 40. How can packet capture help troubleshoot SSH?

The following command can show whether TCP port 22 traffic reaches the EC2 instance:

```bash
sudo tcpdump -nn -i any 'tcp port 22'
```

This helps distinguish between:

- Traffic not reaching EC2.
- Security configuration issues.
- SSH service problems.
- Unexpected source addresses.

---

## 41. Why should EC2 instances in an Auto Scaling Group be treated as disposable?

Because Auto Scaling can replace instances due to:

- Health failures.
- Scaling operations.
- Maintenance.
- Configuration updates.

Applications should therefore avoid storing irreplaceable state on individual EC2 instances.

---

## 42. What would happen if the Launch Template did not contain the EFS bootstrap configuration?

A replacement EC2 instance could launch successfully but would not necessarily:

- Install EFS utilities.
- Mount EFS.
- Configure `/etc/fstab`.
- Create the Apache shared path.

The target might even pass a simple health check while the shared application endpoint remained unavailable.

---

## 43. What is the difference between high availability and persistence in this architecture?

High availability is provided by components such as:

- Multiple EC2 instances.
- Multiple Availability Zones.
- Application Load Balancer.
- Auto Scaling.

Persistence is provided by services such as:

- Amazon EFS for shared files.
- Amazon RDS for relational data.

These solve different architectural requirements.

---

## 44. Why is storing shared state locally on Auto Scaling instances an architectural problem?

Because requests can reach different instances.

Example:

```text
Request 1
   │
   ▼
EC2-A
Upload file
```

Later:

```text
Request 2
   │
   ▼
EC2-B
File not found
```

Shared storage prevents this problem when filesystem semantics are required.

---

## 45. What security improvements could be added to a production implementation?

Possible improvements include:

- IAM authorization for EFS.
- EFS Access Points.
- EFS File System Policies.
- HTTPS on the ALB.
- AWS WAF.
- Private administration through Systems Manager.
- Centralized logging.
- Monitoring and alerting.
- Automated infrastructure deployment.

---

# Solutions Architect

## 46. A company runs a Linux application across multiple EC2 instances and requires a shared POSIX-compatible filesystem. Which AWS storage service would you recommend?

Amazon EFS.

It provides managed shared file storage using NFS and can be accessed by multiple EC2 instances.

---

## 47. A workload requires a boot disk for an EC2 instance. Would you use EFS?

Normally, no.

Amazon EBS is the typical service for EC2 boot volumes because it provides block storage.

---

## 48. An application stores millions of images and accesses them through HTTP APIs. Would EFS always be the best choice?

No.

Amazon S3 would often be a better choice for object-based assets when filesystem semantics are not required.

Storage selection should be based on workload requirements.

---

## 49. How would you design shared storage for EC2 instances distributed across two Availability Zones?

A typical design would use:

```text
              Regional Amazon EFS
                 /            \
                /              \
        Mount Target A     Mount Target B
              │                 │
              ▼                 ▼
           EC2 AZ-A          EC2 AZ-B
```

Security Groups would restrict NFS TCP/2049 access to authorized application instances.

---

## 50. Why would you select Regional EFS for a Multi-AZ application?

Regional EFS is designed to provide shared file storage across multiple Availability Zones.

This aligns with applications that require high availability across AZ boundaries.

---

## 51. How does EFS complement an Auto Scaling architecture?

Auto Scaling manages replaceable compute capacity.

EFS provides persistent shared application files.

Together:

```text
Auto Scaling
     │
     ▼
Replaceable EC2
     │
     ▼
Persistent EFS
```

This decouples compute lifecycle from file storage lifecycle.

---

## 52. How would you design the Security Group relationship between EC2 and EFS?

I would create a dedicated EFS Security Group with an inbound rule:

```text
Protocol: TCP
Port: 2049
Source: Application EC2 Security Group
```

I would avoid public NFS access.

---

## 53. Why is referencing another Security Group useful in an Auto Scaling environment?

New EC2 instances can receive different private IP addresses.

If access is based on the application Security Group instead of individual IP addresses, replacement instances automatically satisfy the EFS network rule.

---

## 54. How would you make the EFS configuration reproducible?

I would automate it through infrastructure and instance bootstrap mechanisms such as:

- Launch Templates.
- User Data.
- Configuration management.
- Infrastructure as Code.

The configuration should not depend on manual SSH commands.

---

## 55. What architecture pattern does Lab 08 demonstrate?

The main pattern is:

```text
Replaceable Compute
        +
Shared Persistent Storage
```

More specifically:

```text
                    Internet
                       │
                       ▼
              Application Load Balancer
                       │
                       ▼
                Auto Scaling Group
                  /           \
                 ▼             ▼
               EC2-A         EC2-B
                  \           /
                   \         /
                    ▼       ▼
                    Amazon EFS
```

---

## 56. Where does Amazon RDS fit into this architecture?

Amazon RDS stores relational application data.

Amazon EFS stores shared filesystem data.

The architecture therefore separates:

```text
Compute
   │
   ▼
Amazon EC2

Shared Files
   │
   ▼
Amazon EFS

Relational Data
   │
   ▼
Amazon RDS
```

---

## 57. What would you consider before choosing EFS instead of S3?

I would evaluate whether the application requires:

- POSIX filesystem semantics.
- Directory structures.
- Shared file locking.
- NFS access.
- Existing filesystem-based application compatibility.

If the workload can use object APIs, Amazon S3 may be more appropriate.

---

## 58. What would you consider before choosing EFS instead of EBS?

I would evaluate whether storage must be shared concurrently across multiple compute instances.

For traditional block storage requirements, EBS may be more appropriate.

For shared NFS file access, EFS is usually the better fit.

---

## 59. How would you validate that an Auto Scaling architecture is truly independent of individual EC2 instances?

I would intentionally replace an EC2 instance and verify that:

1. Auto Scaling launches a replacement.
2. Bootstrap configuration executes automatically.
3. EFS mounts automatically.
4. Existing shared files remain accessible.
5. Apache serves the application.
6. The new target becomes healthy.
7. ALB traffic continues to work.

This is stronger evidence than simply checking that two instances are currently running.

---

## 60. What was the most important architectural outcome of Lab 08?

The application no longer depends on an individual EC2 instance for shared file persistence.

The final design separates:

```text
EC2
→ Replaceable compute

Amazon EFS
→ Shared persistent filesystem

Amazon RDS
→ Persistent relational data
```

This improves scalability, recoverability, and operational consistency.

---

# Scenario-Based Review

## 61. Scenario: A replacement EC2 launches but `/shared/` returns 404. What do you check first?

I would connect to the replacement instance and verify:

```bash
rpm -q amazon-efs-utils
df -hT | grep efs
grep efs /etc/fstab
ls -lah /var/www/html/
cat /mnt/efs/shared/index.html
curl http://localhost/shared/
```

This determines whether the problem is:

- Package installation.
- EFS mounting.
- Shared data.
- Symbolic link.
- Apache.

---

## 62. Scenario: `curl localhost/shared/` works but the ALB URL does not. Where is the likely problem domain?

If local application validation succeeds, I would move outward and inspect:

```text
EC2
  ↓
Target Group
  ↓
ALB Listener / Rules
  ↓
Client
```

I would especially inspect all registered targets for inconsistent configurations.

---

## 63. Scenario: The EC2 instance cannot reach EFS on port 2049. What should be reviewed?

Review:

- EFS Mount Target availability.
- EFS Security Group inbound NFS rule.
- EC2 Security Group outbound rules.
- VPC routing.
- Network ACLs if customized.
- Availability Zone and subnet configuration.
- DNS resolution.

---

## 64. Scenario: Two EC2 instances need to share user-uploaded files. Would copying files between the instances be a good design?

Generally, no.

Manual or custom file synchronization adds complexity and can introduce consistency problems.

If the application requires a shared filesystem, Amazon EFS is a more appropriate managed solution.

---

## 65. Scenario: The company wants the cheapest storage for old files that are rarely accessed. What EFS feature should be considered?

EFS lifecycle management and lower-cost storage classes can be considered for infrequently accessed data.

The exact policy should be selected according to workload access patterns and current AWS pricing.

---

# Rapid-Fire Questions

## 66. EFS storage type?

```text
File storage
```

## 67. EFS protocol?

```text
NFS
```

## 68. EFS NFS port?

```text
TCP 2049
```

## 69. EFS mount point in Lab 08?

```text
/mnt/efs
```

## 70. Shared application directory?

```text
/mnt/efs/shared
```

## 71. Apache shared path?

```text
/var/www/html/shared
```

## 72. Persistent Linux mount configuration?

```text
/etc/fstab
```

## 73. EFS package used on Amazon Linux?

```text
amazon-efs-utils
```

## 74. Encryption in transit?

```text
TLS
```

## 75. Shared storage survives EC2 replacement?

```text
Yes
```

## 76. Should NFS port 2049 be publicly exposed?

```text
No
```

## 77. Does a Healthy ALB target guarantee every application route works?

```text
No
```

## 78. Main purpose of the Launch Template in this lab?

```text
Reproducible and automated EC2 configuration
```

## 79. Main purpose of Auto Scaling?

```text
Maintain and adjust application compute capacity
```

## 80. Main purpose of EFS in this architecture?

```text
Shared persistent file storage
```

---

# Interview Summary

The most important concepts to remember from Lab 08 are:

```text
Amazon EFS
   │
   ├── File storage
   ├── NFS
   ├── TCP 2049
   ├── Shared access
   ├── Mount Targets
   ├── Multi-AZ architecture
   ├── Encryption at rest
   ├── TLS in transit
   └── Persistent storage
```

and:

```text
Application Load Balancer
          │
          ▼
   Auto Scaling Group
      /         \
     ▼           ▼
   EC2-A       EC2-B
      \         /
       \       /
        ▼     ▼
       Amazon EFS
```

The central architectural principle is:

> EC2 instances should be replaceable, while persistent application data should remain outside the lifecycle of individual compute instances.

---

# How to Explain Lab 08 in an Interview

A concise technical explanation is:

> In Lab 08, I integrated Amazon EFS into an existing AWS web architecture using an Application Load Balancer and an EC2 Auto Scaling Group. I configured a Regional EFS file system with Mount Targets for the application Availability Zones and restricted NFS access on TCP port 2049 using Security Group references. I mounted EFS using TLS and configured persistent mounting through `/etc/fstab`. I then updated the EC2 Launch Template User Data so replacement instances could automatically install the EFS utilities, mount the shared filesystem, and expose the shared content through Apache. Finally, I validated the architecture by replacing an Auto Scaling instance and confirming that the new instance could access the existing EFS data. During troubleshooting, I also identified obsolete targets in the ALB Target Group that caused intermittent `Not Found` responses.