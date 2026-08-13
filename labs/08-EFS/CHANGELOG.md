# Changelog

All notable changes to **Lab 08 – Amazon Elastic File System (EFS)** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/).

---

## [Unreleased]

No pending changes.

---

## [1.0.0] - 2026-08-13

### Added

- Amazon EFS integration with the existing NovaCommerce AWS architecture.
- Regional Amazon EFS file system for shared persistent application storage.
- EFS Mount Targets across the Availability Zones used by the application tier.
- Dedicated EFS Security Group for NFS communication.
- NFS access over TCP port `2049` from the application EC2 Security Group.
- Encryption at rest for the Amazon EFS file system.
- TLS encryption for EFS traffic between EC2 and Amazon EFS.
- EFS mount point at:

  ```text
  /mnt/efs
  ```

- Shared application directory at:

  ```text
  /mnt/efs/shared
  ```

- Persistent EFS mounting through:

  ```text
  /etc/fstab
  ```

- Apache integration with shared EFS content through:

  ```text
  /var/www/html/shared
  ```

- Symbolic link between the Apache document root and the shared EFS directory.
- Shared web page used to validate access from multiple EC2 instances.
- Persistent test file used to validate shared storage across instances.
- EC2 replacement validation through the Auto Scaling Group.
- Validation of persistent shared content after EC2 replacement.
- Validation of persistent EFS mounting after an EC2 reboot.
- Application Load Balancer validation for the `/shared/` application path.
- Documentation for the complete Lab 08 implementation.

### Changed

- Extended the existing NovaCommerce architecture with a shared persistent file-storage layer.
- Updated the EC2 bootstrap process to include Amazon EFS configuration.
- Updated the EC2 Launch Template configuration to automate EFS integration.
- Updated Auto Scaling instances so newly launched EC2 resources can automatically access existing shared storage.
- Extended the Apache configuration to serve both local instance-specific content and shared EFS-backed content.
- Updated the application architecture from:

  ```text
  ALB
   │
   ▼
  EC2 Auto Scaling
   │
   ▼
  Local Application Storage
  ```

  to:

  ```text
                 ALB
                  │
                  ▼
           Auto Scaling Group
             /          \
            ▼            ▼
          EC2-A        EC2-B
            \            /
             \          /
              ▼        ▼
              Amazon EFS
  ```

### Fixed

- Resolved SSH connectivity issues caused by a mismatch between the expected client public IP and the actual source IP observed by the EC2 instance.
- Identified the actual SSH source address using:

  ```bash
  echo $SSH_CONNECTION
  ```

- Used packet-level inspection to validate SSH traffic reaching the EC2 instance.
- Resolved missing `amazon-efs-utils` on EC2 instances.
- Automated installation of EFS utilities for replacement instances.
- Resolved the requirement for manual EFS configuration on newly launched Auto Scaling instances.
- Resolved intermittent `Not Found` responses when accessing:

  ```text
  /shared/
  ```

  through the Application Load Balancer.

- Identified obsolete EC2 instances that remained registered in the Target Group.
- Deregistered obsolete targets that did not contain the current EFS application configuration.
- Validated the Target Group with only the current application instances.
- Confirmed that the shared application page remained consistently available through the ALB after Target Group cleanup.

### Security

- Restricted Amazon EFS network access to authorized application resources.
- Limited NFS communication to:

  ```text
  TCP 2049
  ```

- Used Security Group references instead of exposing NFS publicly.
- Enabled encryption at rest for shared application files.
- Enabled TLS encryption in transit for EFS mounts.
- Used AWS Systems Manager Session Manager as an administrative access path during troubleshooting where applicable.

---

# Documentation Added

The first complete release of Lab 08 includes the following documentation:

```text
lab-08-amazon-efs/
│
├── README.md
├── CHANGELOG.md
├── commands.md
├── troubleshooting.md
├── study-notes.md
├── interview-questions.md
├── resources.md
│
├── scripts/
│   └── script.sh
│
├── architecture/
│   ├── README.md
│   ├── architecture-decisions.md
│   └── lab-08-efs-architecture.png
│
└── diagrams/
    └── lab-08-efs-architecture.drawio
```

---

# Architecture Evolution

Lab 08 extends the infrastructure developed in the previous portfolio laboratories.

The main architectural change introduced in this release is the separation of persistent shared application files from the EC2 compute lifecycle.

## Before Lab 08

```text
                         Internet
                            │
                            ▼
                Application Load Balancer
                            │
                            ▼
                    Auto Scaling Group
                       │         │
                       ▼         ▼
                    EC2-A       EC2-B
                       │         │
                       ▼         ▼
                  Local Files Local Files
```

Each EC2 instance depended primarily on its own local filesystem.

---

## After Lab 08

```text
                         Internet
                            │
                            ▼
                Application Load Balancer
                            │
                            ▼
                    Auto Scaling Group
                       │         │
                       ▼         ▼
                    EC2-A       EC2-B
                       │         │
                       └────┬────┘
                            │
                        TCP 2049
                            │
                            ▼
                       Amazon EFS
                            │
                            ▼
                  Shared Persistent Files
```

The compute layer can now be replaced independently from the shared application files.

---

# Validation Completed

The following implementation tests were completed for the initial release:

| Validation | Status |
|---|:---:|
| Amazon EFS created | ✅ |
| EFS network access configured | ✅ |
| NFS TCP/2049 configured | ✅ |
| EFS utilities installed | ✅ |
| EFS mounted on EC2 | ✅ |
| TLS mount validated | ✅ |
| `/etc/fstab` configured | ✅ |
| EFS survives EC2 reboot | ✅ |
| Shared file created | ✅ |
| Shared file accessible from another EC2 | ✅ |
| Apache symbolic link configured | ✅ |
| `/shared/` works locally | ✅ |
| Launch Template updated | ✅ |
| Replacement EC2 automatically configured | ✅ |
| Existing EFS data available after replacement | ✅ |
| Target Group reviewed | ✅ |
| Obsolete targets deregistered | ✅ |
| Current targets healthy | ✅ |
| `/shared/` works through ALB | ✅ |

---

# Key Architectural Outcome

The major outcome of version `1.0.0` is the transition toward a more resilient application architecture based on:

```text
Replaceable Compute
        +
Automated Bootstrap
        +
Shared Persistent Storage
```

The resulting storage responsibilities are separated as follows:

```text
EC2
 │
 └── Replaceable application compute


Amazon EFS
 │
 └── Shared persistent filesystem


Amazon RDS
 │
 └── Persistent relational data
```

This allows the Auto Scaling Group to replace application instances without losing the shared files stored in Amazon EFS.

---

# Release Summary

Version `1.0.0` represents the completed implementation and validation of Amazon EFS within the NovaCommerce AWS portfolio architecture.

The release demonstrates:

- Shared file storage.
- Persistent application data.
- Multi-instance access.
- EC2 Auto Scaling integration.
- Automated instance bootstrap.
- Application Load Balancer integration.
- Network security using Security Groups.
- Encryption at rest.
- Encryption in transit.
- Instance replacement without shared-data loss.
- Real AWS infrastructure troubleshooting.