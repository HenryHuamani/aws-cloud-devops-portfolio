# Lab 08 – Amazon Elastic File System (EFS)

## Resources

This document contains official AWS documentation and reference material related to the services and concepts implemented in Lab 08.

The primary focus is Amazon EFS integration with Amazon EC2, Auto Scaling, Launch Templates, Security Groups, and highly available application architectures.

---

# 1. Amazon EFS Documentation

## Amazon Elastic File System Documentation

Official Amazon EFS documentation portal.

https://docs.aws.amazon.com/efs/

Topics:

- Amazon EFS fundamentals
- File systems
- Mount Targets
- Performance
- Throughput
- Security
- Monitoring
- Troubleshooting

---

## What is Amazon EFS?

https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html

Useful for reviewing:

- Amazon EFS architecture
- NFS support
- Regional and One Zone file systems
- Performance modes
- Throughput modes
- Scalability
- Supported AWS compute services

---

## How Amazon EFS Works

https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html

Useful for understanding:

- EFS architecture
- VPC integration
- EC2 connectivity
- NFS communication
- Mount Targets

---

# 2. Amazon EFS and Amazon EC2

## Use Amazon EFS with Amazon EC2 Linux Instances

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEFS.html

Useful for reviewing:

- EFS integration with EC2
- Security Groups
- NFS connectivity
- Automatic mounting
- EC2 User Data integration

---

## Mounting Amazon EFS Using DNS

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html

Useful for understanding:

- EFS DNS names
- Mount Targets
- Availability Zone resolution
- EC2 mounting procedures

---

## Mounting Amazon EFS Using a Mount Target IP Address

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-ip-addr.html

Useful for:

- Mounting through a Mount Target IP
- NFS configuration
- Troubleshooting DNS-related mounting problems

---

# 3. Amazon EFS Security

## Using VPC Security Groups with Amazon EFS

https://docs.aws.amazon.com/efs/latest/ug/network-access.html

Important concept:

```text
EC2
 │
 │ TCP 2049
 ▼
EFS Mount Target
```

The EFS Mount Target Security Group must allow inbound NFS traffic on TCP port `2049` from authorized clients.

This was one of the main security controls implemented in Lab 08.

---

## Changing Mount Target Security Groups

https://docs.aws.amazon.com/efs/latest/ug/manage-fs-access-update-mount-target-config-sg.html

Useful for:

- Modifying EFS Security Groups
- Managing Mount Target access
- Troubleshooting NFS connectivity

---

## EC2 Security Group Rules Reference

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html

Useful for reviewing common Security Group rules including:

- SSH
- HTTP
- HTTPS
- NFS
- Database connectivity

---

# 4. Amazon EFS Mount Helper

## Mounting Amazon EFS

Amazon EFS can be mounted using the EFS mount helper.

Example:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

Official documentation:

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html

---

## Encryption in Transit

The EFS mount helper supports TLS.

Example:

```bash
sudo mount -t efs -o tls <EFS_ID>:/ /mnt/efs
```

This protects communication between the EC2 instance and Amazon EFS.

---

# 5. Persistent EFS Mounting

Amazon EFS can be configured to mount automatically through:

```text
/etc/fstab
```

Example used in this laboratory:

```text
fs-04a66a073c14f5d1c:/ /mnt/efs efs _netdev,tls 0 0
```

Important options:

```text
_netdev
```

Indicates that the file system requires network connectivity.

```text
tls
```

Enables encryption in transit.

---

# 6. EFS Access Points

## Mounting with EFS Access Points

https://docs.aws.amazon.com/efs/latest/ug/mounting-access-points.html

EFS Access Points can provide application-specific access to a shared EFS file system.

They can help enforce:

- Root directories
- POSIX users
- POSIX groups
- Application-specific filesystem access

Access Points were not required for the basic Lab 08 implementation but are an important concept for production architectures.

---

# 7. Amazon EC2 Auto Scaling

## Amazon EC2 Auto Scaling Documentation

https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html

Useful for reviewing:

- Auto Scaling Groups
- Desired capacity
- Minimum capacity
- Maximum capacity
- Instance replacement
- Health checks
- Scaling policies

---

# 8. EC2 Launch Templates

## Auto Scaling Launch Templates

https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html

Useful for:

- Launch Template configuration
- Version management
- AMI configuration
- Instance types
- Security Groups
- User Data
- Auto Scaling integration

Launch Template versioning was important in Lab 08 because a new version was created to introduce automatic EFS configuration.

---

## Launch Template Examples

https://docs.aws.amazon.com/autoscaling/ec2/userguide/examples-launch-templates-aws-cli.html

Useful for reviewing:

- Creating Launch Templates
- Creating new versions
- Configuring User Data
- Updating Auto Scaling Groups
- Security Group configuration

---

# 9. EC2 User Data

## Launch Template Advanced Settings

https://docs.aws.amazon.com/autoscaling/ec2/userguide/advanced-settings-for-your-launch-template.html

User Data allows EC2 instances to execute initialization scripts when they launch.

In Lab 08, User Data was responsible for:

```text
Install Apache
        │
        ▼
Install amazon-efs-utils
        │
        ▼
Create EFS mount point
        │
        ▼
Configure /etc/fstab
        │
        ▼
Mount Amazon EFS
        │
        ▼
Create shared application path
```

---

# 10. Application Load Balancer

## Application Load Balancer Documentation

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html

Useful for reviewing:

- Application Load Balancers
- Listeners
- Listener rules
- Target Groups
- Health checks
- Multi-AZ traffic distribution

---

# 11. Target Groups

## Target Groups for Application Load Balancers

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html

Useful for understanding:

- Target registration
- Target deregistration
- Health checks
- Target states
- Application routing

A key troubleshooting lesson from Lab 08 involved obsolete EC2 instances remaining registered in the Target Group.

---

# 12. AWS Systems Manager Session Manager

## Session Manager

https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html

Session Manager provides administrative access to EC2 instances without requiring direct inbound SSH connectivity.

It was useful during Lab 08 for:

- Checking the SSH service
- Inspecting EFS configuration
- Validating mounts
- Troubleshooting network connectivity
- Validating replacement EC2 instances

---

# 13. Amazon EFS Architecture Reference

Important architecture pattern:

```text
                         Internet
                            │
                            ▼
                Application Load Balancer
                            │
                            ▼
                       Target Group
                       │          │
                       ▼          ▼
                    EC2-A       EC2-B
                       │          │
                       └────┬─────┘
                            │
                        TCP 2049
                            │
                            ▼
                       Amazon EFS
```

This architecture separates:

```text
Compute
   ↓
Amazon EC2

Shared Files
   ↓
Amazon EFS

Relational Data
   ↓
Amazon RDS
```

---

# 14. AWS Well-Architected Framework

## AWS Well-Architected Framework

https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html

The Lab 08 architecture relates to several Well-Architected pillars.

### Reliability

- Multiple Availability Zones
- Auto Scaling
- Replaceable EC2 instances
- Persistent shared storage

### Security

- Security Groups
- Encryption at rest
- Encryption in transit
- Restricted NFS connectivity

### Operational Excellence

- Launch Template versioning
- Automated User Data
- Repeatable EC2 configuration

### Cost Optimization

- Managed storage
- EFS lifecycle capabilities
- Elastic storage capacity

---

# 15. AWS Architecture Center

## AWS Architecture Center

https://aws.amazon.com/architecture/

Useful for exploring:

- Reference architectures
- Cloud design patterns
- Highly available applications
- Storage architectures
- Multi-AZ designs
- AWS Well-Architected solutions

---

# 16. Recommended Study Order

For reviewing the concepts from Lab 08, use the following order:

```text
1. What is Amazon EFS?
        │
        ▼
2. How Amazon EFS Works
        │
        ▼
3. EFS Mount Targets
        │
        ▼
4. Security Groups + TCP 2049
        │
        ▼
5. EFS Mount Helper + TLS
        │
        ▼
6. Persistent /etc/fstab Mount
        │
        ▼
7. EC2 Launch Templates
        │
        ▼
8. EC2 User Data
        │
        ▼
9. Auto Scaling
        │
        ▼
10. ALB + Target Groups
        │
        ▼
11. Multi-AZ Architecture
```

---

# 17. Lab Repository References

The following repository files complement the AWS documentation.

## Main Laboratory

```text
README.md
```

Complete implementation and validation process.

---

## Commands

```text
commands.md
```

Commands used during implementation and troubleshooting.

---

## Study Notes

```text
study-notes.md
```

Technical concepts and architecture notes.

---

## Troubleshooting

```text
troubleshooting.md
```

Real issues encountered during the laboratory and their resolutions.

---

## Interview Questions

```text
interview-questions.md
```

Technical and scenario-based interview preparation.

---

## Architecture

```text
architecture/README.md
```

Architecture overview.

---

## Architecture Decisions

```text
architecture/architecture-decisions.md
```

Explanation of the architectural decisions made during the laboratory.

---

## Automation Script

```text
scripts/script.sh
```

Bootstrap script used to automatically configure EC2 instances with Amazon EFS.

---

# Final Reference Summary

The most important official AWS documentation for Lab 08 is:

| Topic | Documentation |
|-------|---------------|
| Amazon EFS | Amazon EFS User Guide |
| EFS Architecture | How Amazon EFS Works |
| EFS + EC2 | Use Amazon EFS with EC2 |
| EFS Security | Using VPC Security Groups |
| EFS Mounting | Mounting Amazon EFS |
| EFS Access Points | Mounting with EFS Access Points |
| Auto Scaling | EC2 Auto Scaling User Guide |
| Launch Templates | Auto Scaling Launch Templates |
| User Data | Launch Template Advanced Settings |
| ALB | Application Load Balancer Documentation |
| Target Groups | ALB Target Groups |
| Session Manager | AWS Systems Manager Session Manager |
| Architecture | AWS Architecture Center |
| Best Practices | AWS Well-Architected Framework |

---

# Official Documentation Policy

For AWS implementation decisions, configuration syntax, limits, service capabilities, and security recommendations, always verify the current AWS documentation.

AWS services evolve over time, and configuration options may change after this laboratory was completed.