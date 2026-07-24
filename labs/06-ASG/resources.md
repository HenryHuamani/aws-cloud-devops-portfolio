# Architecture Documentation

## Lab 06 – Amazon EC2 Auto Scaling

---

# Table of Contents

1. Overview
2. Architecture Objectives
3. Architecture Diagram
4. Component Description
5. Request Flow
6. High Availability Design
7. Security Considerations
8. AWS Best Practices
9. Well-Architected Framework
10. Future Improvements
11. Summary

---

# 1. Overview

This laboratory implements a highly available web application using **Amazon EC2 Auto Scaling** integrated with an **Application Load Balancer**.

The architecture automatically provisions and maintains EC2 instances while distributing incoming traffic across multiple Availability Zones.

The primary objective is to provide a scalable, resilient and automated infrastructure that minimizes manual intervention and improves application availability.

---

# 2. Architecture Objectives

The architecture was designed to achieve the following objectives:

- Maintain a fixed number of healthy EC2 instances.
- Automatically replace failed instances.
- Distribute traffic evenly.
- Eliminate single points of failure.
- Support future scaling policies.
- Prepare the infrastructure for production workloads.

---

# 3. Architecture Diagram

The architecture diagram for this laboratory is located in:

```
architecture/
```

The editable Draw.io source file is available in:

```
architecture/
```

The diagram illustrates every AWS component used during the laboratory together with the logical communication flow.

---

# 4. Component Description

## Internet

The Internet represents client requests entering the AWS environment.

Users access the application through the public DNS name of the Application Load Balancer.

---

## Amazon VPC

The Virtual Private Cloud provides logical network isolation for all AWS resources.

Within the VPC, networking resources are organized into multiple Availability Zones to improve resilience.

Responsibilities:

- Network isolation
- IP address management
- Routing
- Security

---

## Public Subnets

The infrastructure spans two public subnets located in separate Availability Zones.

Purpose:

- High Availability
- Redundancy
- Fault Isolation

Each subnet contains one or more EC2 instances managed by Auto Scaling.

---

## Application Load Balancer

The Application Load Balancer is the public entry point for the application.

Responsibilities:

- Receive HTTP requests.
- Perform Health Checks.
- Route traffic.
- Balance requests.
- Remove unhealthy instances.

The ALB distributes traffic only to healthy EC2 instances registered in the Target Group.

---

## Target Group

The Target Group maintains the list of backend EC2 instances available to receive traffic.

Responsibilities:

- Register EC2 instances.
- Execute Health Checks.
- Remove unhealthy instances.
- Return healthy targets to the Load Balancer.

---

## Auto Scaling Group

The Auto Scaling Group continuously maintains the desired infrastructure state.

Responsibilities:

- Launch EC2 instances.
- Replace unhealthy instances.
- Maintain Desired Capacity.
- Scale infrastructure.
- Distribute instances across Availability Zones.

This is the central automation component of the laboratory.

---

## Launch Template

The Launch Template defines how every EC2 instance should be created.

Configuration includes:

- Amazon Linux 2023
- Instance Type
- Security Groups
- User Data
- Storage
- IMDSv2
- Key Pair

Every new EC2 instance launched by Auto Scaling inherits this configuration.

---

## Amazon EC2

Amazon EC2 provides the compute resources that host the web application.

Each instance automatically:

- Executes User Data.
- Installs Apache.
- Generates a dynamic HTML page.
- Retrieves metadata using IMDSv2.
- Registers with the Target Group.

---

# 5. Request Flow

The following sequence describes how a client request is processed.

```
User

↓

Internet

↓

Application Load Balancer

↓

Target Group

↓

Healthy EC2 Instance

↓

Apache HTTP Server

↓

Dynamic HTML Page

↓

User Response
```

If an EC2 instance fails:

```
Health Check Failure

↓

Target Group marks instance unhealthy

↓

Auto Scaling terminates instance

↓

Launch Template creates replacement

↓

Health Checks pass

↓

Traffic resumes
```

This process occurs automatically without administrator intervention.

---

# 6. High Availability Design

The architecture achieves High Availability through several design decisions.

## Multi-AZ Deployment

Resources are distributed across multiple Availability Zones.

Benefits:

- Fault isolation.
- Reduced downtime.
- Improved resiliency.

---

## Automatic Recovery

If an EC2 instance fails:

- Auto Scaling launches another instance.
- The Target Group validates its health.
- The Load Balancer begins routing traffic.

---

## Stateless Compute

Every EC2 instance is identical.

No manual configuration exists.

All configuration originates from:

- Launch Template
- User Data

This enables automatic replacement at any time.

---

# 7. Security Considerations

Several AWS security recommendations were applied.

## Security Groups

Control inbound and outbound traffic.

---

## IMDSv2

Protects EC2 metadata using temporary session tokens.

---

## IAM

Permissions follow the Principle of Least Privilege.

---

## Automated Provisioning

Infrastructure consistency reduces configuration drift and security risks.

---

# 8. AWS Best Practices

This architecture follows multiple AWS recommendations.

- Launch Templates instead of Launch Configurations.
- Multi-AZ deployment.
- Auto Scaling.
- Elastic Load Balancing.
- Health Checks.
- Automated provisioning.
- Immutable infrastructure principles.
- Standardized server configuration.
- Infrastructure automation.

---

# 9. AWS Well-Architected Framework

This laboratory demonstrates several Well-Architected pillars.

## Operational Excellence

- Automation
- Repeatable deployments

---

## Security

- Security Groups
- IAM
- IMDSv2

---

## Reliability

- Auto Scaling
- Health Checks
- Multi-AZ deployment

---

## Performance Efficiency

- Elastic infrastructure
- Load Balancer
- Traffic distribution

---

## Cost Optimization

- Automatic Scale In
- Efficient resource utilization

---

# 10. Future Improvements

The architecture can be extended by integrating additional AWS services.

Examples include:

- Amazon RDS
- Amazon CloudWatch
- Route 53
- AWS WAF
- AWS Shield
- Amazon CloudFront
- Amazon EFS
- Amazon ElastiCache
- AWS Systems Manager
- Terraform
- GitHub Actions
- Amazon ECS
- Amazon EKS

These services will be implemented in future laboratories.

---

# 11. Summary

This laboratory demonstrates how Amazon EC2 Auto Scaling can be combined with an Application Load Balancer and Launch Templates to build a resilient and highly available web application.

The implemented architecture provides:

- Automated infrastructure provisioning.
- Automatic instance replacement.
- Multi-Availability Zone deployment.
- Health monitoring.
- Elastic traffic distribution.
- Operational consistency.

This design serves as the foundation for future laboratories involving databases, containers, Infrastructure as Code and CI/CD pipelines.