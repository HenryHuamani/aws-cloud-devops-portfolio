# Amazon EC2 Auto Scaling

![AWS](https://img.shields.io/badge/AWS-EC2%20Auto%20Scaling-orange?logo=amazonaws)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Level](https://img.shields.io/badge/Level-Intermediate-blue)
![Region](https://img.shields.io/badge/Region-us--east--2-lightgrey)

---

# Overview

This laboratory demonstrates how to deploy a highly available web application using **Amazon EC2 Auto Scaling**, **Application Load Balancer (ALB)** and **Launch Templates**.

Instead of manually provisioning EC2 instances, Auto Scaling automatically launches and maintains healthy instances across multiple Availability Zones, improving application availability, fault tolerance and operational efficiency.

The infrastructure was designed following AWS Well-Architected Framework recommendations for High Availability and Elasticity.

---

# Learning Objectives

At the end of this laboratory you will be able to:

- Understand Amazon EC2 Auto Scaling architecture.
- Create and configure Launch Templates.
- Automate EC2 deployment using User Data.
- Deploy instances across multiple Availability Zones.
- Integrate Auto Scaling with an Application Load Balancer.
- Configure Target Groups and Health Checks.
- Verify automatic instance registration.
- Understand High Availability and Fault Tolerance concepts.
- Prepare infrastructure for future dynamic scaling policies.

---

# AWS Services Used

| Service | Purpose |
|----------|---------|
| Amazon EC2 | Virtual servers |
| Amazon EC2 Auto Scaling | Automatic instance management |
| Launch Template | Instance configuration template |
| Elastic Load Balancer (ALB) | Traffic distribution |
| Target Group | Health monitoring |
| Amazon VPC | Network isolation |
| Public Subnets | Multi-AZ deployment |
| Security Groups | Firewall configuration |
| IAM | Service permissions |

---

# Architecture

The laboratory architecture consists of:

- Internet
- Application Load Balancer
- Target Group
- Auto Scaling Group
- Launch Template
- Two EC2 Instances
- Public Subnet A
- Public Subnet B
- Amazon VPC

The architecture distributes incoming HTTP requests across multiple Availability Zones while automatically maintaining the desired number of healthy EC2 instances.

> The detailed architecture diagram is available in the **architecture/** directory.

---

# Laboratory Workflow

The implementation followed these steps:

1. Create Launch Template.
2. Configure User Data.
3. Create Auto Scaling Group.
4. Attach Application Load Balancer.
5. Associate Target Group.
6. Launch EC2 instances.
7. Verify Health Checks.
8. Test Application Load Balancer DNS.
9. Validate automatic instance registration.

---

# Environment Configuration

| Component | Value |
|-----------|-------|
| AWS Region | us-east-2 (Ohio) |
| Instance Type | t3.micro |
| Operating System | Amazon Linux 2023 |
| Web Server | Apache HTTP Server |
| Protocol | HTTP |
| Listener Port | 80 |
| Desired Capacity | 2 |
| Minimum Capacity | 2 |
| Maximum Capacity | 4 |

---

# Launch Template

The Launch Template defines the standard configuration that Amazon EC2 Auto Scaling uses whenever a new EC2 instance must be launched.

Instead of manually configuring every new virtual machine, the Auto Scaling Group references this template to ensure that every instance is created with identical settings.

The Launch Template contains:

- Amazon Linux 2023 AMI
- t3.micro instance type
- Apache HTTP Server installation
- Existing SSH Key Pair
- Existing Security Group
- User Data bootstrap script
- IMDSv2 metadata configuration
- GP3 EBS root volume

Using a Launch Template improves consistency, simplifies infrastructure management and enables automatic recovery when instances fail.

---

# User Data Configuration

A User Data script was configured to automatically provision every EC2 instance during its first boot.

The script performs the following tasks:

- Updates the operating system.
- Installs Apache HTTP Server.
- Enables and starts the Apache service.
- Retrieves instance metadata using IMDSv2.
- Generates a dynamic HTML page.
- Displays:
  - Instance ID
  - Hostname
  - Private IP Address
  - Availability Zone
- Restarts Apache.

Unlike the previous laboratory, the script no longer contains hardcoded server names.

Instead, every instance retrieves its own information directly from the EC2 Instance Metadata Service Version 2 (IMDSv2), allowing the same script to be reused by every instance created by the Auto Scaling Group.

---

# Auto Scaling Group Configuration

The Auto Scaling Group (ASG) is responsible for maintaining the desired number of healthy EC2 instances.

The following configuration was implemented:

| Parameter | Value |
|-----------|-------|
| Desired Capacity | 2 |
| Minimum Capacity | 2 |
| Maximum Capacity | 4 |

This configuration guarantees that:

- Two EC2 instances are always available.
- Failed instances are automatically replaced.
- Future scaling policies can increase the number of instances up to four without modifying the infrastructure.

The Auto Scaling Group also distributes instances across multiple Availability Zones to improve application availability.

---

# Load Balancer Integration

The Auto Scaling Group was integrated with the existing Application Load Balancer created in the previous laboratory.

The architecture uses the following components:

| Component | Name |
|----------|------|
| Application Load Balancer | portfolio-alb |
| Target Group | portfolio-web-tg |
| Auto Scaling Group | portfolio-asg |
| Launch Template | portfolio-web-template |

Instead of registering EC2 instances manually, every instance launched by the Auto Scaling Group is automatically registered inside the Target Group.

This significantly reduces administrative effort while ensuring that only healthy instances receive production traffic.

---

# Health Checks

Two health validation mechanisms were configured.

## EC2 Health Checks

Amazon EC2 verifies whether the virtual machine itself is operational.

If the instance fails due to hardware or operating system issues, Auto Scaling automatically replaces it.

## Elastic Load Balancer Health Checks

The Application Load Balancer periodically verifies that the web application is responding correctly.

Only instances that successfully respond to the configured Health Check receive incoming traffic.

If Apache stops responding while the EC2 instance remains running, the instance will be marked as **Unhealthy** and replaced automatically by the Auto Scaling Group.

This combination provides automatic recovery at both the infrastructure and application layers.

---

# Verification

After the Auto Scaling Group was successfully deployed, several validation tests were performed to ensure that every AWS component was operating correctly.

The following items were verified during the laboratory:

- Launch Template created successfully.
- Auto Scaling Group deployed without errors.
- Two EC2 instances automatically launched.
- EC2 instances distributed across multiple Availability Zones.
- Instances automatically registered in the Target Group.
- Health Checks reporting **Healthy** status.
- Application Load Balancer successfully routing HTTP traffic.
- Dynamic web page displaying instance-specific information.
- User Data executed successfully during instance initialization.

The laboratory confirmed that the infrastructure operates as expected and is ready for future dynamic scaling policies.

---

# Evidence

The following screenshots document the implementation process.

| Evidence | Description |
|----------|-------------|
| 01 | Launch Template Details |
| 02 | User Data Configuration |
| 03 | Launch Template Successfully Created |
| 04 | Auto Scaling Group Configuration |
| 05 | Auto Scaling Group Successfully Created |
| 06 | EC2 Instances Running |
| 07 | Auto Scaling Activity History |
| 08 | Target Group Registration |
| 09 | Target Health Status |
| 10 | Application Load Balancer |
| 11 | Web Application Verification |
| 12 | Dynamic Instance Information |

Additional evidence is available in the **evidence/** directory.

---

# Results

The objectives defined at the beginning of the laboratory were successfully achieved.

## Infrastructure

✔ Launch Template successfully configured.

✔ Auto Scaling Group deployed.

✔ Two EC2 instances automatically provisioned.

✔ Multi-AZ deployment completed.

✔ Application Load Balancer integrated.

✔ Target Group associated successfully.

✔ Health Checks passing.

✔ Dynamic User Data executed correctly.

---

## Operational Benefits

The implemented architecture provides several operational advantages:

- Improved High Availability.
- Automatic replacement of unhealthy instances.
- Simplified infrastructure administration.
- Reduced manual provisioning.
- Consistent EC2 configuration.
- Foundation for automatic scaling policies.
- Better application resiliency.

---

# AWS Best Practices Applied

During this laboratory, several AWS Well-Architected Framework recommendations were applied.

## Reliability

- Multi-AZ deployment.
- Automatic instance replacement.
- Health monitoring.
- Elastic Load Balancing.

## Operational Excellence

- Infrastructure standardization using Launch Templates.
- Automated server provisioning through User Data.
- Consistent EC2 configuration.

## Performance Efficiency

- Load distribution across multiple EC2 instances.
- Efficient traffic routing using Target Groups.

## Security

- Security Groups.
- Existing SSH Key Pair.
- IMDSv2 metadata service.
- Least privilege IAM configuration.

---

# Lessons Learned

This laboratory provided practical experience with one of the most important AWS services for building highly available applications.

Key concepts reinforced include:

- Difference between Launch Templates and EC2 Instances.
- Auto Scaling lifecycle.
- Automatic infrastructure provisioning.
- High Availability architecture.
- Elastic Load Balancer integration.
- Health Check mechanisms.
- Multi-Availability Zone deployments.
- User Data automation.
- EC2 Instance Metadata Service Version 2 (IMDSv2).

Understanding these concepts is fundamental before implementing advanced AWS services such as Amazon RDS, Amazon ECS, Amazon EKS and Terraform.

---

# Future Improvements

Possible enhancements for this architecture include:

- Dynamic Scaling Policies.
- CloudWatch Metrics.
- CloudWatch Alarms.
- HTTPS using AWS Certificate Manager.
- Route 53 DNS integration.
- Amazon RDS backend.
- Docker containerization.
- Infrastructure as Code with Terraform.
- CI/CD using GitHub Actions.
- Monitoring with CloudWatch Dashboards.

These topics will be covered in future laboratories of this portfolio.

---

# References

- AWS Documentation – Amazon EC2 Auto Scaling
- AWS Documentation – Launch Templates
- AWS Documentation – Elastic Load Balancing
- AWS Documentation – Target Groups
- AWS Documentation – Health Checks
- AWS Documentation – EC2 Instance Metadata Service (IMDSv2)
- AWS Well-Architected Framework
- AWS Architecture Center

---

# Repository Structure

```text
Lab-06-EC2-Auto-Scaling/
│
├── README.md
├── commands.md
├── study-notes.md
├── troubleshooting.md
├── interview-questions.md
│
├── architecture/
│   ├── README.md
│   ├── source/
│   └── export/
│
└── evidence/

```

The complete bootstrap script is available in:

scripts/userdata.sh

---

# Author

**Henry Junior Huamani Huanuqueño**

AWS Cloud & DevOps Portfolio

Version: **v1.3.0**

AWS Region: **us-east-2 (Ohio)**

Laboratory: **Lab 06 – Amazon EC2 Auto Scaling**

Last Updated: **July 2026**