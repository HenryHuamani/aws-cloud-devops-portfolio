# Resources – Lab 09

This file contains the official AWS documentation and high-quality reference material relevant to Lab 09 – Amazon CloudWatch Monitoring, Alarms & Auto Scaling Validation.

The references are organized by the AWS services and technical concepts implemented in the NovaCommerce architecture.

---

# 1. AWS Well-Architected Framework

## AWS Well-Architected Framework

Official guidance for designing secure, reliable, efficient, cost-effective, and sustainable workloads in AWS.

https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html

## Reliability Pillar

Relevant to:

- Multi-AZ design
- Automatic recovery
- Auto Scaling
- Health checks
- Failure management

https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html

## Security Pillar

Relevant to:

- Security Groups
- Network isolation
- Least privilege
- Data protection
- Infrastructure protection

https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html

## Performance Efficiency Pillar

Relevant to:

- Elastic compute capacity
- Horizontal scaling
- Workload performance

https://docs.aws.amazon.com/wellarchitected/latest/performance-efficiency-pillar/welcome.html

## Operational Excellence Pillar

Relevant to:

- Monitoring
- Observability
- Operational events
- Troubleshooting
- Continuous improvement

https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/welcome.html

---

# 2. Amazon VPC

## Amazon VPC Documentation

https://docs.aws.amazon.com/vpc/

## What Is Amazon VPC?

https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

## VPC Subnets

Relevant to the public/private and Multi-AZ subnet design used in the laboratory.

https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html

## Route Tables

Relevant to public and private routing.

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

## Internet Gateways

Relevant to the public route:

```text
0.0.0.0/0 → Internet Gateway
```

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html

## Network ACLs

Relevant to subnet-level stateless network filtering.

https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html

## Security Groups

Relevant to stateful resource-level traffic control.

https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html

---

# 3. Amazon EC2

## Amazon EC2 Documentation

https://docs.aws.amazon.com/ec2/

## Amazon EC2 User Guide

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html

## EC2 Instance Types

Relevant to the `t3.micro` instances used in the laboratory.

https://aws.amazon.com/ec2/instance-types/

## EC2 Launch Templates

Relevant to:

```text
portfolio-web-template
```

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html

## User Data and Shell Scripts

Relevant to automated Apache installation and instance initialization.

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

---

# 4. EC2 Instance Metadata Service

## Instance Metadata and User Data

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html

## Configure Instance Metadata Options

Relevant to IMDSv2.

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html

The laboratory used IMDSv2 to retrieve:

- Instance ID
- Availability Zone
- Private IPv4 address

These values were displayed on the NovaCommerce validation page to identify which EC2 backend handled each ALB request.

---

# 5. Elastic Load Balancing

## Elastic Load Balancing Documentation

https://docs.aws.amazon.com/elasticloadbalancing/

## Application Load Balancers

Relevant to:

```text
portfolio-alb
```

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html

## ALB Listeners

Relevant to the HTTP listener configured on port 80.

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html

## Target Groups

Relevant to:

```text
portfolio-web-tg
```

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html

## Health Checks

Relevant to the Target Group configuration:

```text
Protocol: HTTP
Path: /
Port: Traffic Port
Success Code: 200
```

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html

---

# 6. Amazon EC2 Auto Scaling

## Amazon EC2 Auto Scaling Documentation

https://docs.aws.amazon.com/autoscaling/ec2/

## What Is Amazon EC2 Auto Scaling?

https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html

## Create an Auto Scaling Group Using a Launch Template

Relevant to the integration between:

```text
portfolio-asg
portfolio-web-template
```

https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-launch-template.html

## Attach a Load Balancer to an Auto Scaling Group

Relevant to the integration between the ASG and Target Group.

https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html

## Health Checks for Auto Scaling Instances

Relevant to automatic instance recovery.

https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-checks-overview.html

## Auto Scaling Group Capacity

Relevant to:

```text
Minimum: 2
Desired: 2
Maximum: 4
```

https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-capacity-limits.html

---

# 7. Target Tracking Scaling Policies

## Target Tracking Scaling Policies

Relevant to the CPU-based scaling policy used in the laboratory.

https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html

Laboratory configuration:

```text
Metric: Average CPU Utilization
Target: 50%
Instance Warmup: 300 seconds
Scale In: Enabled
```

## Dynamic Scaling

https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html

## Instance Warmup

Relevant to understanding why newly launched instances are not immediately treated as fully contributing capacity during scaling calculations.

https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-default-instance-warmup.html

---

# 8. Amazon EFS

## Amazon EFS Documentation

https://docs.aws.amazon.com/efs/

## What Is Amazon EFS?

https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html

## Mount Targets

Relevant to the Multi-AZ EFS network configuration.

https://docs.aws.amazon.com/efs/latest/ug/accessing-fs.html

## EFS Security

https://docs.aws.amazon.com/efs/latest/ug/security-considerations.html

## EFS Network Access

Relevant to NFS:

```text
TCP 2049
```

https://docs.aws.amazon.com/efs/latest/ug/network-access.html

## Mounting EFS File Systems

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html

## Amazon EFS Utilities

Relevant to:

```bash
amazon-efs-utils
```

https://docs.aws.amazon.com/efs/latest/ug/using-amazon-efs-utils.html

## EFS Encryption

Relevant to the encrypted `novacommerce-efs` filesystem.

https://docs.aws.amazon.com/efs/latest/ug/encryption.html

## EFS Backup

https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html

---

# 9. Amazon RDS

## Amazon RDS Documentation

https://docs.aws.amazon.com/rds/

## What Is Amazon RDS?

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html

## Amazon RDS for MySQL

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html

## Security Groups for Amazon RDS

Relevant to:

```text
portfolio-rds-sg
TCP 3306
```

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html

## Working with a DB Instance in a VPC

Relevant to private database networking.

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html

## RDS Public Accessibility

Relevant to the database configuration:

```text
Publicly accessible: No
```

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html

## Automated Backups

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html

## Monitoring Amazon RDS

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MonitoringOverview.html

---

# 10. Amazon CloudWatch

## Amazon CloudWatch Documentation

https://docs.aws.amazon.com/cloudwatch/

## What Is Amazon CloudWatch?

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html

## CloudWatch Metrics

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html

## CloudWatch Alarms

Relevant to CPU, target health, and infrastructure alarm validation.

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html

## CloudWatch Dashboards

Relevant to the centralized NovaCommerce monitoring dashboard.

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html

## EC2 Metrics

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html

## Application Load Balancer Metrics

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html

## Auto Scaling Group Metrics

Relevant to the monitoring issue encountered when Auto Scaling graphs initially showed no data.

https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-metrics.html

---

# 11. Amazon SNS

## Amazon SNS Documentation

https://docs.aws.amazon.com/sns/

## What Is Amazon SNS?

https://docs.aws.amazon.com/sns/latest/dg/welcome.html

## CloudWatch Alarm Notifications

Relevant to CloudWatch and SNS integration.

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Notify_Users_Alarm_Changes.html

---

# 12. Linux and Apache

## Apache HTTP Server Documentation

https://httpd.apache.org/docs/

Apache was used as the web server running on the Auto Scaling EC2 instances.

Useful service commands documented in `commands.md` include:

```bash
sudo systemctl start httpd
sudo systemctl stop httpd
sudo systemctl restart httpd
sudo systemctl status httpd
```

---

# 13. stress-ng

## stress-ng Project

`stress-ng` was used only in the controlled laboratory environment to generate CPU load and validate Auto Scaling behavior.

Project repository:

https://github.com/ColinIanKing/stress-ng

Example used for testing:

```bash
stress-ng --cpu 2 --timeout 600s
```

The test allowed validation of:

```text
2 EC2 instances
      ↓
CPU utilization increase
      ↓
Target Tracking
      ↓
Scale-out
      ↓
4 EC2 instances
```

---

# 14. AWS Architecture Guidance

## AWS Architecture Center

https://aws.amazon.com/architecture/

Useful for reviewing reference architectures and AWS design patterns.

## AWS Prescriptive Guidance

https://docs.aws.amazon.com/prescriptive-guidance/

Useful for architecture patterns, migrations, security, resilience, and operational practices.

---

# 15. Key Laboratory Documentation Map

Use the following references depending on the topic being reviewed.

| Topic | Primary Documentation |
|------|------------------------|
| VPC | Amazon VPC User Guide |
| Public/Private Subnets | VPC Subnet Documentation |
| Route Tables | VPC Route Tables |
| Internet Gateway | VPC Internet Gateway |
| NACL | VPC Network ACLs |
| Security Groups | VPC Security Groups |
| EC2 | EC2 User Guide |
| Launch Template | EC2 Launch Templates |
| User Data | EC2 User Data |
| IMDSv2 | EC2 Instance Metadata |
| ALB | Application Load Balancer Guide |
| Target Groups | ALB Target Groups |
| Health Checks | ALB Target Group Health Checks |
| Auto Scaling | EC2 Auto Scaling User Guide |
| Target Tracking | Target Tracking Scaling Policies |
| EFS | Amazon EFS User Guide |
| RDS | Amazon RDS User Guide |
| CloudWatch | Amazon CloudWatch User Guide |
| SNS | Amazon SNS Developer Guide |

---

# 16. Recommended Study Order

For reviewing this laboratory before an interview, use the following order:

```text
1. VPC
   ↓
2. Public vs Private Subnets
   ↓
3. Security Groups / NACL
   ↓
4. EC2 Launch Templates
   ↓
5. Application Load Balancer
   ↓
6. Target Groups / Health Checks
   ↓
7. EC2 Auto Scaling
   ↓
8. Target Tracking
   ↓
9. EFS
   ↓
10. RDS
   ↓
11. CloudWatch
   ↓
12. SNS
   ↓
13. High Availability
   ↓
14. Elasticity
   ↓
15. Self-Healing
```

---

# 17. Repository Cross-References

Additional Lab 09 documentation:

```text
README.md
CHANGELOG.md
commands.md
interview-questions.md
resources.md
study-notes.md
troubleshooting.md
```

Architecture:

```text
architecture/lab-09-architecture.png
```

Editable diagram:

```text
diagrams/lab-09-architecture.drawio
```

Evidence:

```text
evidence/
```

---

# Notes

- AWS documentation should be considered the primary technical reference.
- AWS service behavior and console interfaces can evolve over time.
- Avoid documenting secrets, AWS credentials, private keys, database passwords, or sensitive configuration values in the repository.
- Commands that generate artificial CPU load should only be used in controlled test environments.
- The architecture documented in this laboratory is intended for learning and portfolio demonstration and should be reviewed for production-specific security, cost, compliance, and operational requirements before production use.

---

**Lab Status:** ✅ Completed
