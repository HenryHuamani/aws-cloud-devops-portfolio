# Lab 08 – Amazon Elastic File System (EFS)

## Study Notes

This document summarizes the key architectural concepts learned during Lab 08.

The objective is to understand not only how Amazon EFS works, but also when and why it should be used in a cloud architecture.

---

# 1. What is Amazon EFS?

Amazon Elastic File System (Amazon EFS) is a fully managed, scalable file storage service designed for workloads that require shared access from multiple compute resources.

Amazon EFS uses the Network File System (NFS) protocol and can be mounted simultaneously by multiple Amazon EC2 instances.

Typical use cases include:

- Shared application files.
- Web content.
- User uploads.
- Content management systems.
- Shared configuration files.
- Development environments.
- Container workloads.
- Analytics workloads.

---

# 2. Why EFS was required in NovaCommerce

The NovaCommerce architecture already used:

- Application Load Balancer.
- Auto Scaling Group.
- Multiple EC2 instances.
- Amazon RDS.

However, files stored locally on EC2 instances were not suitable for a scalable architecture.

EC2 instances in an Auto Scaling Group are replaceable.

If application files exist only on one EC2 instance:

```text
EC2-A
 └── local file
```

and EC2-A is terminated, that local application file may no longer be available to replacement instances.

Amazon EFS provides a shared storage layer:

```text
EC2-A ───┐
         │
         ▼
      Amazon EFS
         ▲
         │
EC2-B ───┘
```

Both instances access the same file system.

---

# 3. Compute should be replaceable

One of the main architectural lessons from this laboratory is:

> Compute instances should be replaceable while application data remains persistent.

In an Auto Scaling architecture, EC2 instances should not contain irreplaceable application state.

Instead:

```text
EC2
│
├── Application runtime
├── Temporary data
└── Replaceable configuration

Persistent data
│
├── Amazon RDS
├── Amazon EFS
└── Amazon S3
```

This separation improves:

- Availability.
- Scalability.
- Recoverability.
- Automation.
- Operational consistency.

---

# 4. EFS vs EBS vs S3

Understanding when to use EFS requires comparing it with other AWS storage services.

## Amazon EBS

Amazon Elastic Block Store provides block storage primarily for EC2 instances.

Characteristics:

- Block storage.
- Attached to EC2.
- Typically associated with a specific Availability Zone.
- Suitable for operating systems and databases.
- Behaves similarly to a virtual disk.

Example:

```text
EC2
 │
 ▼
EBS Volume
```

Typical use cases:

- Boot volumes.
- Databases.
- Application disks.
- Transactional workloads.

---

## Amazon EFS

Amazon Elastic File System provides shared network file storage.

Characteristics:

- File storage.
- Uses NFS.
- Can be mounted by multiple EC2 instances.
- Regional architecture.
- Automatically scales storage capacity.

Example:

```text
EC2-A ─┐
       │
       ▼
      EFS
       ▲
       │
EC2-B ─┘
```

Typical use cases:

- Shared web content.
- CMS applications.
- Shared application directories.
- User uploads.
- Multi-instance workloads.

---

## Amazon S3

Amazon Simple Storage Service provides object storage.

Characteristics:

- Object-based storage.
- Accessed through APIs.
- Extremely scalable.
- Highly durable.
- Does not behave like a traditional mounted Linux file system by default.

Example:

```text
Application
    │
    ▼
Amazon S3
```

Typical use cases:

- Images.
- Documents.
- Backups.
- Static website assets.
- Data lakes.
- Logs.

---

## Quick Comparison

| Feature | EBS | EFS | S3 |
|---------|-----|-----|----|
| Storage Type | Block | File | Object |
| Shared between EC2 | Limited | Yes | Via API |
| Protocol | Block device | NFS | HTTPS/API |
| Multi-AZ access | No traditional shared block use | Yes | Yes |
| Typical Use | OS / DB volumes | Shared filesystem | Objects / backups |
| Mounted like Linux FS | Yes | Yes | No, normally |
| Automatically scales storage | Depends on configuration | Yes | Yes |

---

# 5. Network File System (NFS)

Amazon EFS uses the Network File System protocol.

The default EFS NFS communication uses:

```text
TCP 2049
```

In this laboratory:

```text
EC2 Security Group
       │
       │ TCP/2049
       ▼
portfolio-efs-sg
       │
       ▼
Amazon EFS
```

The EFS Security Group only allows NFS traffic from the Security Group associated with the application EC2 instances.

This is more secure than allowing:

```text
0.0.0.0/0
```

or a broad VPC CIDR when it is unnecessary.

---

# 6. EFS Mount Targets

Amazon EC2 instances access Amazon EFS through Mount Targets.

A Mount Target provides a network interface inside a VPC subnet.

Conceptually:

```text
EC2
 │
 ▼
Subnet
 │
 ▼
EFS Mount Target
 │
 ▼
Amazon EFS
```

For a Multi-AZ architecture, Mount Targets should exist in the Availability Zones where application instances need access.

In this laboratory:

```text
us-east-2a
 └── EFS Mount Target

us-east-2b
 └── EFS Mount Target
```

This allows EC2 instances in both Availability Zones to access the same Regional EFS file system.

---

# 7. Regional EFS

The NovaCommerce EFS was created using a Regional file system.

A Regional EFS design provides high availability across multiple Availability Zones.

Architecture:

```text
Availability Zone A
      │
      ▼
Mount Target
      │
      │
      ▼
   Amazon EFS
      ▲
      │
      │
Mount Target
      ▲
      │
Availability Zone B
```

This design is appropriate for highly available applications using Auto Scaling across multiple Availability Zones.

---

# 8. EFS Storage Classes and Lifecycle Management

Amazon EFS supports storage classes that can reduce storage costs depending on access frequency.

Examples include:

- Standard.
- Infrequent Access (IA).
- Archive.

Lifecycle policies can automatically transition files based on access patterns.

In this laboratory:

```text
Transition to IA:
30 days since last access

Transition to Archive:
90 days since last access
```

This demonstrates how storage cost can be optimized automatically.

---

# 9. Performance Mode

The file system was configured using:

```text
General Purpose
```

General Purpose mode is suitable for most latency-sensitive applications.

Typical workloads include:

- Web applications.
- Content management systems.
- Development environments.
- General application file storage.

---

# 10. Throughput Mode

The laboratory used:

```text
Elastic Throughput
```

Elastic Throughput automatically scales throughput according to workload activity.

This reduces the need to manually provision throughput for unpredictable workloads.

---

# 11. Encryption at Rest

Amazon EFS was created with encryption at rest enabled.

Encryption at rest protects stored file data.

Conceptually:

```text
Application
   │
   ▼
Amazon EFS
   │
   ▼
Encrypted stored data
```

Encryption should generally be enabled for production workloads.

---

# 12. Encryption in Transit

The EFS file system was mounted using TLS.

Example:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

The persistent `/etc/fstab` entry also uses:

```text
tls
```

Example:

```text
fs-xxxxxxxx:/ /mnt/efs efs _netdev,tls 0 0
```

This protects network traffic between EC2 and Amazon EFS.

---

# 13. Why `_netdev` is important

The `/etc/fstab` configuration used:

```text
_netdev
```

This indicates that the file system depends on network availability.

A network file system should not be treated like a local disk during system startup.

Example:

```text
fs-xxxxxxxx:/ /mnt/efs efs _netdev,tls 0 0
```

---

# 14. Persistent Mounts

A manual mount:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

works only for the current running system.

To survive reboots, the configuration must be persistent.

This was achieved using:

```text
/etc/fstab
```

After reboot, the EC2 instance automatically restored access to EFS.

---

# 15. EFS and Auto Scaling

Amazon EFS is especially useful with EC2 Auto Scaling.

Without shared storage:

```text
EC2-A
 └── local files

EC2-B
 └── different local files
```

With EFS:

```text
          Auto Scaling Group
            /          \
           ▼            ▼
        EC2-A          EC2-B
           \            /
            \          /
             ▼        ▼
             Amazon EFS
```

All instances can use the same application files.

---

# 16. Launch Template Automation

Manual EFS configuration is not sufficient for Auto Scaling.

Every replacement instance must automatically configure itself.

The Launch Template User Data was updated to:

- Install Apache.
- Install `amazon-efs-utils`.
- Create the mount point.
- Configure `/etc/fstab`.
- Mount Amazon EFS.
- Create the shared application directory.
- Create the Apache symbolic link.

This supports the principle:

> Instances should bootstrap themselves automatically.

---

# 17. Why the symbolic link was used

Apache serves content from:

```text
/var/www/html
```

EFS was mounted at:

```text
/mnt/efs
```

Instead of moving the entire Apache document root, the laboratory created:

```text
/var/www/html/shared
          │
          ▼
     /mnt/efs/shared
```

using a symbolic link.

This preserved the existing local Apache landing page while adding shared EFS-backed content.

---

# 18. Local vs Shared Application Data

The laboratory demonstrates two different types of application content.

## Local EC2 content

```text
/var/www/html/index.html
```

This page contains dynamic EC2 information such as:

- Instance ID.
- Hostname.
- Private IP.
- Availability Zone.

It belongs to the individual EC2 instance.

---

## Shared EFS content

```text
/mnt/efs/shared/index.html
```

This file belongs to Amazon EFS.

Every properly configured EC2 instance can access the same file.

Apache exposes it through:

```text
/var/www/html/shared
```

---

# 19. Auto Scaling Replacement Validation

One of the most important tests in the laboratory involved replacing an EC2 instance.

Sequence:

```text
Existing EC2
     │
     ▼
Detached
     │
     ▼
ASG actual capacity < desired capacity
     │
     ▼
Auto Scaling launches replacement
     │
     ▼
Launch Template v5
     │
     ▼
User Data executes
     │
     ▼
Amazon EFS mounted automatically
     │
     ▼
Existing shared content available
```

This proves that EFS data is independent of an individual EC2 lifecycle.

---

# 20. Application Load Balancer Integration

The final application path is:

```text
Internet
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
/var/www/html/shared
   │
   ▼
/mnt/efs/shared
   │
   ▼
Amazon EFS
```

The user does not need to know which EC2 instance responds.

Every correctly configured target can serve the same shared content.

---

# 21. Target Group Health Checks

A key lesson from the troubleshooting phase was that:

> A healthy target does not mean every application endpoint is working.

The Target Group health check may validate:

```text
/
```

while another endpoint:

```text
/shared/
```

could still be unavailable.

Therefore, when ALB responses are inconsistent:

- Inspect all registered targets.
- Test each target locally.
- Compare application configuration.
- Remove obsolete targets.

---

# 22. Old Targets and Configuration Drift

The laboratory experienced a real example of configuration drift.

Older EC2 instances remained registered in the Target Group.

Those instances were healthy on the health-check path but did not contain the new EFS `/shared/` configuration.

This caused intermittent results:

```text
Request 1 → Updated EC2 → Success

Request 2 → Old EC2 → Not Found
```

After obsolete targets were deregistered:

```text
Total Targets: 2
Healthy: 2
Unhealthy: 0
```

the application became consistent.

---

# 23. Configuration Drift

Configuration drift occurs when infrastructure components expected to be identical have different configurations.

Example:

```text
EC2-A
├── EFS mounted
└── /shared configured

EC2-B
├── EFS mounted
└── /shared missing
```

Auto Scaling architectures should minimize configuration drift through automation.

Launch Templates and User Data help ensure instance consistency.

---

# 24. EFS Security Layers

Amazon EFS security involves several layers.

## Network Security

Security Groups control:

```text
Who can reach TCP/2049?
```

---

## Encryption in Transit

TLS protects:

```text
EC2 ↔ EFS communication
```

---

## Encryption at Rest

Encryption protects:

```text
Data stored inside EFS
```

---

## IAM / File System Policies

More advanced architectures can use:

- IAM authorization.
- EFS Access Points.
- EFS File System Policies.

These features were not the main focus of this laboratory.

---

# 25. EFS Access Points

EFS Access Points can provide application-specific entry points into an EFS file system.

They can enforce:

- Root directories.
- POSIX users.
- POSIX groups.
- Permissions.

Example architecture:

```text
Application A
     │
     ▼
EFS Access Point A
     │
     ▼
Amazon EFS

Application B
     │
     ▼
EFS Access Point B
```

Access Points are useful when multiple applications share the same file system.

---

# 26. High Availability

The final architecture distributes compute across multiple Availability Zones.

```text
                  ALB
                 /   \
                /     \
          EC2 AZ-A   EC2 AZ-B
               \     /
                \   /
                 EFS
```

If an EC2 instance fails:

- Auto Scaling can launch another instance.
- EFS data remains available.
- The replacement instance can mount the same file system.
- ALB can route traffic to healthy targets.

---

# 27. Fault Tolerance vs High Availability

These concepts are related but different.

## High Availability

The system remains accessible through redundant resources.

Example:

```text
Multiple EC2 instances
Multiple Availability Zones
ALB
Regional EFS
```

## Fault Tolerance

The architecture continues operating with minimal or no interruption after component failure.

A fully fault-tolerant architecture normally requires additional design considerations beyond this laboratory.

---

# 28. EFS Cost Considerations

Amazon EFS charges primarily based on storage and selected features.

Cost considerations may include:

- Stored GB.
- Storage class.
- Throughput mode.
- Backup storage.
- Data access patterns.

Lifecycle management can reduce storage costs for infrequently accessed files.

Unused lab resources should be cleaned up after testing.

---

# 29. When should EFS be used?

Consider EFS when:

- Multiple Linux EC2 instances require shared file access.
- Applications need NFS semantics.
- Instances are distributed across Availability Zones.
- Storage must survive EC2 replacement.
- Storage capacity should scale automatically.

---

# 30. When should EFS NOT be the first choice?

EFS may not be the best option when:

- The application needs object storage → consider Amazon S3.
- The workload needs high-performance block storage → consider Amazon EBS.
- A Windows SMB file share is required → consider Amazon FSx for Windows File Server.
- The application does not require shared filesystem semantics.

---

# 31. EFS vs FSx

Amazon EFS is primarily designed for Linux/NFS workloads.

Amazon FSx provides managed file systems for specialized workloads.

Examples include:

- FSx for Windows File Server.
- FSx for Lustre.
- FSx for NetApp ONTAP.
- FSx for OpenZFS.

The correct service depends on application requirements.

---

# 32. Well-Architected Principles Demonstrated

This laboratory relates to several AWS Well-Architected concepts.

## Reliability

- Multi-AZ deployment.
- Auto Scaling instance replacement.
- Persistent shared storage.

## Security

- Security Group isolation.
- Encryption at rest.
- Encryption in transit.

## Operational Excellence

- Automated EC2 bootstrap.
- Launch Template versioning.
- Repeatable configuration.

## Cost Optimization

- EFS lifecycle management.
- Managed storage scaling.

---

# 33. Key Architectural Pattern

The key pattern implemented in Lab 08 is:

```text
Stateless / Replaceable Compute
             +
Shared Persistent Storage
```

or:

```text
Application Load Balancer
          │
          ▼
Auto Scaling Group
     /         \
    ▼           ▼
  EC2          EC2
    \           /
     \         /
        EFS
```

This pattern allows the compute layer to scale or be replaced independently from application file storage.

---

# 34. Important Commands to Remember

Install EFS utilities:

```bash
sudo dnf install -y amazon-efs-utils
```

Mount EFS using TLS:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

Verify EFS:

```bash
df -hT | grep efs
```

Persistent mount:

```text
<EFS_ID>:/ /mnt/efs efs _netdev,tls 0 0
```

Verify mount:

```bash
mountpoint /mnt/efs
```

Validate shared content:

```bash
cat /mnt/efs/shared/index.html
```

Test Apache:

```bash
curl http://localhost/shared/
```

---

# 35. Important Ports

| Service | Port | Protocol |
|---------|-----:|----------|
| HTTP | 80 | TCP |
| SSH | 22 | TCP |
| Amazon EFS / NFS | 2049 | TCP |
| Amazon RDS MySQL | 3306 | TCP |

For Amazon EFS, remember:

```text
NFS = TCP 2049
```

---

# 36. Important Paths

```text
/mnt/efs
```

Amazon EFS mount point.

```text
/mnt/efs/shared
```

Shared web application content.

```text
/var/www/html
```

Apache local document root.

```text
/var/www/html/shared
```

Symbolic link to EFS shared content.

```text
/etc/fstab
```

Persistent mount configuration.

---

# 37. Interview-Level Summary

Amazon EFS is a managed shared file system for AWS workloads.

In an EC2 Auto Scaling architecture, EFS can separate persistent application files from the lifecycle of individual EC2 instances.

The recommended architecture includes:

- A Regional EFS file system.
- Mount Targets in required Availability Zones.
- Security Groups allowing TCP/2049 only from authorized clients.
- Encryption at rest.
- TLS encryption in transit.
- Automated mounting through Launch Templates or configuration management.
- Validation that replacement instances can access existing shared files.

---

# Final Study Summary

After completing Lab 08, the following concepts should be clear:

- Amazon EFS is managed file storage.
- EFS uses NFS.
- NFS uses TCP port 2049.
- Multiple EC2 instances can mount the same EFS file system.
- EFS Mount Targets provide VPC network access.
- Regional EFS supports Multi-AZ architectures.
- Encryption can protect data at rest and in transit.
- `/etc/fstab` enables persistent mounts.
- `_netdev` identifies a network-dependent filesystem.
- Auto Scaling EC2 instances should configure EFS automatically.
- Shared data should not depend on an individual EC2 instance.
- ALB health checks do not guarantee every application endpoint works.
- Target Group membership must remain consistent.
- Launch Template automation reduces configuration drift.
- EFS enables shared persistent application storage across replaceable compute instances.