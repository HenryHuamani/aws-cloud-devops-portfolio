# Lab 08 – Amazon Elastic File System (EFS)

## Architecture Decisions

This document explains the main architectural decisions made during Lab 08 and the reasoning behind each choice.

The objective is to demonstrate not only how Amazon EFS was implemented, but also why it was selected and how it integrates with the existing NovaCommerce architecture.

---

# Decision 1 – Use Amazon EFS for Shared Application Storage

## Context

The NovaCommerce application runs across multiple EC2 instances managed by an Auto Scaling Group.

Application files stored locally on individual EC2 instances are not suitable for this architecture because instances can be replaced, terminated, or scaled at any time.

## Decision

Use Amazon Elastic File System as the shared application storage layer.

## Rationale

Amazon EFS provides:

- Shared file access across multiple EC2 instances.
- NFS filesystem semantics.
- Persistent storage independent of EC2 lifecycle.
- Regional architecture.
- Automatic storage scaling.
- Integration with Auto Scaling workloads.

This allows all application instances to access the same shared content.

## Alternative Considered

Amazon EBS was not selected because the requirement involved shared file access across multiple application instances.

Amazon S3 could be appropriate for object-based application assets, but this laboratory specifically required traditional filesystem semantics.

---

# Decision 2 – Use a Regional EFS File System

## Context

The application tier runs across multiple Availability Zones.

## Decision

Deploy Amazon EFS using the Regional file system type.

## Rationale

A Regional EFS file system supports highly available Multi-AZ architectures.

This aligns with the existing NovaCommerce design:

```text
Application Load Balancer
          │
          ▼
Auto Scaling Group
     /           \
    ▼             ▼
EC2 AZ-A        EC2 AZ-B
     \           /
      \         /
       Amazon EFS
```

The file system remains independent of a single Availability Zone.

---

# Decision 3 – Deploy Mount Targets Across Multiple Availability Zones

## Context

EC2 application instances operate in:

```text
us-east-2a
us-east-2b
```

## Decision

Create EFS Mount Targets in both Availability Zones.

## Rationale

Mount Targets provide network access from the VPC to the EFS file system.

Deploying them across the Availability Zones used by the application improves:

- Availability.
- Network locality.
- Application resilience.
- Multi-AZ integration.

---

# Decision 4 – Use a Dedicated EFS Security Group

## Context

Amazon EFS requires NFS communication on TCP port 2049.

## Decision

Create a dedicated Security Group:

```text
portfolio-efs-sg
```

## Rationale

Separating the EFS Security Group from the application Security Group improves clarity and allows storage-specific network controls.

The EFS Security Group only allows:

```text
NFS
TCP
2049
Source: Application EC2 Security Group
```

This follows the principle of least privilege.

---

# Decision 5 – Use Security Group References Instead of Broad CIDR Rules

## Context

Only the NovaCommerce EC2 application instances require access to Amazon EFS.

## Decision

Use the EC2 application Security Group as the source of the EFS inbound rule.

## Rationale

This is preferable to:

```text
0.0.0.0/0
```

or a broad VPC CIDR because access is based on resource identity rather than IP address ranges.

Benefits include:

- Reduced attack surface.
- Easier scaling.
- Automatic authorization of replacement instances using the same Security Group.
- Better operational consistency.

---

# Decision 6 – Enable Encryption at Rest

## Context

The EFS file system stores application data that should remain protected.

## Decision

Enable Amazon EFS encryption at rest.

## Rationale

Encryption at rest protects stored data and is considered a standard security best practice for production workloads.

---

# Decision 7 – Require Encryption in Transit

## Context

Application instances communicate with Amazon EFS over the VPC network.

## Decision

Mount Amazon EFS using TLS.

Example:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

The persistent mount also includes:

```text
tls
```

## Rationale

TLS protects data while it travels between EC2 and Amazon EFS.

The architecture therefore protects:

```text
Data at Rest      → Encrypted
Data in Transit   → TLS
```

---

# Decision 8 – Use `/etc/fstab` for Persistent Mounting

## Context

A manual EFS mount would disappear after an EC2 reboot.

## Decision

Store the EFS mount configuration inside:

```text
/etc/fstab
```

using:

```text
fs-04a66a073c14f5d1c:/ /mnt/efs efs _netdev,tls 0 0
```

## Rationale

This allows Amazon EFS to be mounted automatically after the operating system restarts.

The `_netdev` option identifies the filesystem as network-dependent.

---

# Decision 9 – Automate EFS Configuration in the EC2 Launch Template

## Context

Auto Scaling can create replacement instances at any time.

Manual installation and mounting would create configuration drift.

## Decision

Automate EFS configuration through EC2 Launch Template User Data.

## Rationale

Each replacement instance automatically:

- Installs Apache.
- Installs `amazon-efs-utils`.
- Creates the EFS mount point.
- Configures `/etc/fstab`.
- Mounts EFS.
- Creates the shared application directory.
- Creates the Apache symbolic link.

This ensures that new EC2 instances are automatically ready for service.

---

# Decision 10 – Use Launch Template Versioning

## Context

The existing Launch Template already contained configuration from previous laboratories.

## Decision

Create a new Launch Template version instead of modifying an existing version in place.

The final EFS-enabled configuration used:

```text
portfolio-web-template
Version 5
```

## Rationale

Launch Template versioning provides:

- Change history.
- Controlled updates.
- Easier rollback.
- Reproducibility.
- Clear infrastructure evolution.

---

# Decision 11 – Keep the Local Apache Landing Page Separate from Shared EFS Content

## Context

The original Apache page displays EC2-specific metadata.

Examples include:

- Instance ID.
- Hostname.
- Private IP.
- Availability Zone.

This information is different for each EC2 instance.

## Decision

Keep the local Apache landing page at:

```text
/var/www/html/index.html
```

and expose shared EFS content through:

```text
/var/www/html/shared
```

## Rationale

This preserves two useful behaviors:

```text
Local Content
/var/www/html/index.html
→ Instance-specific

Shared Content
/var/www/html/shared
→ Persistent EFS data
```

This clearly demonstrates the difference between local compute state and shared persistent storage.

---

# Decision 12 – Use a Symbolic Link for Apache Shared Content

## Context

Amazon EFS is mounted at:

```text
/mnt/efs
```

while Apache serves files from:

```text
/var/www/html
```

## Decision

Create:

```text
/var/www/html/shared
→
/mnt/efs/shared
```

## Rationale

The symbolic link allows Apache to serve EFS-backed content without changing the complete Apache document root.

This reduces the impact on the existing configuration from previous laboratories.

---

# Decision 13 – Validate EC2 Replacement Instead of Only Testing Manual Mounting

## Context

A successful manual EFS mount does not prove that the architecture works correctly with Auto Scaling.

## Decision

Intentionally detach an EC2 instance with replacement enabled.

## Rationale

This validates the actual operational behavior expected from the architecture.

The test demonstrated:

```text
Existing EC2
     │
     ▼
Detached
     │
     ▼
ASG detects capacity shortage
     │
     ▼
Replacement EC2 launched
     │
     ▼
Launch Template v5 executes
     │
     ▼
EFS mounted automatically
     │
     ▼
Existing shared content available
```

This is more meaningful than validating only a manually configured instance.

---

# Decision 14 – Maintain Desired Capacity During Replacement Testing

## Context

The Auto Scaling Group was configured with:

```text
Desired Capacity: 2
Minimum Capacity: 2
Maximum Capacity: 4
```

## Decision

Keep desired capacity at two during instance replacement.

## Rationale

The purpose of the test was to demonstrate Auto Scaling self-healing behavior.

Reducing desired capacity would not trigger an automatic replacement.

---

# Decision 15 – Let Auto Scaling Manage Current Application Capacity

## Context

The Application Load Balancer Target Group contained older EC2 targets from previous stages of the portfolio.

## Decision

Deregister obsolete targets and retain only the current Auto Scaling application instances.

## Rationale

Outdated targets introduced configuration inconsistency.

Some targets did not include the EFS `/shared/` configuration.

Keeping Target Group membership aligned with the current Auto Scaling environment reduces configuration drift and inconsistent application responses.

---

# Decision 16 – Do Not Rely Only on Target Group Health Checks

## Context

Old EC2 targets remained `Healthy`, but did not provide:

```text
/shared/
```

## Decision

Validate the actual application path in addition to health-check status.

## Rationale

An ALB Target Group health check validates only the configured health-check endpoint.

For example:

```text
/              → Healthy
/shared/       → Not Found
```

Therefore:

```text
Healthy Target ≠ Every Application Route Works
```

Application-level validation is still required.

---

# Decision 17 – Reuse Existing Portfolio Infrastructure

## Context

The following resources already existed from previous laboratories:

- Amazon VPC.
- EC2 instances.
- Application Load Balancer.
- Target Group.
- Auto Scaling Group.
- Launch Template.
- Amazon RDS.
- Security Groups.

## Decision

Integrate Amazon EFS into the existing architecture instead of creating an isolated environment.

## Rationale

Infrastructure reuse demonstrates how real cloud architectures evolve incrementally.

It also provides continuity throughout the portfolio.

---

# Decision 18 – Use EFS Lifecycle Management

## Context

Application files may become infrequently accessed over time.

## Decision

Configure lifecycle transitions.

The laboratory used policies similar to:

```text
30 days → Infrequent Access
90 days → Archive
```

## Rationale

Lifecycle management helps reduce storage costs by automatically moving cold files into lower-cost storage classes.

---

# Decision 19 – Use Elastic Throughput

## Context

The workload in this laboratory does not have predictable throughput requirements.

## Decision

Use:

```text
Elastic Throughput
```

## Rationale

Elastic Throughput allows Amazon EFS to automatically adapt to changing workload activity.

This reduces the need for manual throughput planning during the laboratory.

---

# Decision 20 – Use General Purpose Performance Mode

## Context

NovaCommerce represents a general web application workload.

## Decision

Use:

```text
General Purpose
```

performance mode.

## Rationale

General Purpose mode is appropriate for most latency-sensitive web and application workloads.

---

# Final Architecture

The resulting architecture is:

```text
                           Internet
                              │
                              ▼
                  Application Load Balancer
                       portfolio-alb
                              │
                              ▼
                    portfolio-web-tg
                      │             │
                      ▼             ▼
                  EC2 AZ-A       EC2 AZ-B
                      │             │
                      └──────┬──────┘
                             │
                     NFS TCP/2049
                             │
                             ▼
                       Amazon EFS
                    novacommerce-efs
                       │          │
                       ▼          ▼
                  Mount Target Mount Target
                   us-east-2a   us-east-2b

Persistent relational data
             │
             ▼
        Amazon RDS
```

---

# Architectural Principles Demonstrated

The implementation applies the following principles:

## Separation of Compute and Storage

```text
EC2 = Replaceable Compute
EFS = Persistent Shared Files
RDS = Persistent Relational Data
```

## High Availability

```text
Multiple Availability Zones
+
Application Load Balancer
+
Auto Scaling
+
Regional EFS
```

## Automation

```text
Launch Template
+
User Data
+
Automatic EFS Mount
```

## Least Privilege

```text
EC2 Security Group
        │
        │ NFS TCP/2049
        ▼
EFS Security Group
```

## Infrastructure Consistency

Replacement instances receive the same configuration automatically.

---

# Trade-Offs

Amazon EFS provides shared storage and operational simplicity, but it also introduces trade-offs.

## Advantages

- Fully managed.
- Shared filesystem access.
- Multi-AZ architecture.
- Automatic capacity scaling.
- Integration with EC2 Auto Scaling.
- NFS compatibility.
- Lifecycle management.

## Considerations

- Additional storage cost.
- Network latency compared with local block storage.
- Applications must be compatible with NFS semantics.
- EFS may not be appropriate for workloads better suited to object or block storage.

---

# Alternatives

## Amazon EBS

Better suited for:

- Boot volumes.
- Block storage.
- Database volumes.
- Instance-attached workloads.

## Amazon S3

Better suited for:

- Object storage.
- Static assets.
- Documents.
- Backups.
- Logs.
- API-based storage access.

## Amazon FSx

Better suited for specialized managed file-system requirements such as:

- Windows SMB.
- Lustre.
- NetApp ONTAP.
- OpenZFS.

---

# Final Decision Summary

The final NovaCommerce architecture uses Amazon EFS because the application requires persistent shared file storage across replaceable EC2 instances operating in multiple Availability Zones.

The combination of:

```text
Application Load Balancer
+
Auto Scaling Group
+
EC2 Launch Template
+
Amazon EFS
+
Amazon RDS
```

creates a cloud architecture where application compute can be automatically replaced while both file-based and relational application data remain persistent.