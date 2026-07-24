# Study Notes

## Lab 06 – Amazon EC2 Auto Scaling

---

# Table of Contents

1. What is Amazon EC2 Auto Scaling?
2. Why Auto Scaling?
3. Benefits
4. Auto Scaling Components
5. Launch Templates
6. Auto Scaling Groups
7. Scaling Concepts
8. Health Checks
9. Availability Zones
10. Load Balancer Integration
11. User Data
12. EC2 Instance Metadata Service (IMDSv2)
13. Auto Scaling Lifecycle
14. High Availability
15. Fault Tolerance
16. Horizontal vs Vertical Scaling
17. Best Practices
18. Key Takeaways

---

# 1. What is Amazon EC2 Auto Scaling?

Amazon EC2 Auto Scaling is an AWS service that automatically launches, terminates and replaces Amazon EC2 instances according to the desired capacity and scaling policies configured by the user.

Instead of manually managing virtual servers, Auto Scaling continuously monitors the health of the infrastructure and ensures that the desired number of EC2 instances is always available.

This service is designed to improve application availability, automate infrastructure management and optimize resource utilization.

---

## Key Characteristics

- Automatic instance provisioning.
- Automatic instance replacement.
- High Availability.
- Elastic infrastructure.
- Multi-AZ deployment.
- Integration with Elastic Load Balancing.
- Integration with CloudWatch.
- Automatic scaling.

---

# 2. Why Auto Scaling?

Before Auto Scaling, system administrators had to manually launch or terminate EC2 instances whenever application demand changed.

This approach introduced several challenges:

- Human intervention.
- Increased operational costs.
- Slow response to traffic spikes.
- Single points of failure.
- Higher maintenance effort.

Auto Scaling solves these problems by automatically adjusting infrastructure according to predefined rules.

---

## Example

Without Auto Scaling:

100 users

↓

1 EC2 Instance

↓

CPU reaches 100%

↓

Application becomes slow.

---

With Auto Scaling:

100 users

↓

Application Load Balancer

↓

2 EC2 Instances

↓

Traffic distributed

↓

Lower CPU utilization

↓

Higher availability

---

# 3. Benefits

Amazon EC2 Auto Scaling provides several operational and architectural benefits.

## High Availability

Applications remain available even if one or more EC2 instances fail.

---

## Fault Tolerance

Failed instances are automatically replaced.

---

## Cost Optimization

Infrastructure grows only when necessary and can shrink when demand decreases.

---

## Automation

No manual intervention is required to provision new EC2 instances.

---

## Scalability

Infrastructure can scale horizontally according to business demand.

---

# 4. Auto Scaling Components

A complete Auto Scaling architecture is composed of multiple AWS services.

| Component | Purpose |
|-----------|----------|
| Launch Template | Standard EC2 configuration |
| Auto Scaling Group | Manages EC2 instances |
| EC2 | Compute resources |
| Target Group | Registers healthy instances |
| Application Load Balancer | Distributes traffic |
| CloudWatch | Monitors metrics |
| VPC | Network |
| Subnets | Multi-AZ deployment |

Each component has a specific responsibility within the architecture.

---

# 5. Launch Templates

## What is a Launch Template?

A Launch Template is a reusable configuration blueprint that defines how Amazon EC2 instances should be launched.

Instead of configuring each EC2 instance manually, the Launch Template stores all the required parameters so that every new instance is created consistently.

This approach simplifies infrastructure management, reduces configuration errors and enables automated deployments through services such as Amazon EC2 Auto Scaling.

---

## Information Stored in a Launch Template

A Launch Template can contain:

- Amazon Machine Image (AMI)
- Instance Type
- Key Pair
- Security Groups
- IAM Role
- Storage Configuration (Amazon EBS)
- Network Configuration
- User Data Script
- Metadata Options (IMDSv2)
- Tags

Because all configuration is centralized, every instance launched from the template will have the same baseline configuration.

---

## Advantages

Using Launch Templates provides several benefits:

- Standardized deployments
- Reduced manual configuration
- Faster provisioning
- Version control
- Easy integration with Auto Scaling
- Consistent infrastructure

---

## Versioning

One of the most important features of Launch Templates is versioning.

Every modification creates a new version while preserving previous configurations.

Example:

Version 1

- Amazon Linux 2023
- Apache

↓

Version 2

- Amazon Linux 2023
- Apache
- Docker

↓

Version 3

- Amazon Linux 2023
- Apache
- Docker
- CloudWatch Agent

This makes rollbacks much easier if a deployment introduces issues.

---

# 6. Auto Scaling Groups

## What is an Auto Scaling Group?

An Auto Scaling Group (ASG) is the AWS service responsible for launching, monitoring and terminating EC2 instances.

It continuously ensures that the desired number of healthy instances is running.

The Auto Scaling Group uses a Launch Template as its blueprint whenever a new instance needs to be created.

---

## Main Responsibilities

The Auto Scaling Group can:

- Launch EC2 instances
- Terminate EC2 instances
- Replace unhealthy instances
- Maintain desired capacity
- Distribute instances across Availability Zones
- Integrate with Elastic Load Balancers
- Execute scaling policies

---

## Architecture

Launch Template

↓

Auto Scaling Group

↓

EC2 Instance

↓

Health Checks

↓

Traffic

---

# 7. Capacity Settings

One of the most important concepts in Auto Scaling is capacity management.

Three parameters determine how many EC2 instances are allowed to run.

---

## Minimum Capacity

Minimum Capacity defines the smallest number of EC2 instances that must always remain running.

Example:

Minimum Capacity = 2

Even if demand is very low, two EC2 instances will remain available.

---

## Desired Capacity

Desired Capacity represents the target number of running EC2 instances.

Auto Scaling continuously compares the current number of instances with the desired value.

If an instance fails:

Desired = 2

Current = 1

↓

Auto Scaling launches a new instance.

---

## Maximum Capacity

Maximum Capacity defines the largest number of EC2 instances that Auto Scaling can create.

Example:

Minimum = 2

Desired = 2

Maximum = 4

During high traffic:

2

↓

3

↓

4

Once demand decreases, Auto Scaling can terminate extra instances according to scaling policies.

---

## Capacity Summary

| Parameter | Purpose |
|------------|----------|
| Minimum | Lowest number of instances |
| Desired | Target number of instances |
| Maximum | Highest number of instances |

These settings ensure that applications remain available while preventing uncontrolled resource consumption.

---

# 8. Scaling Policies

Scaling Policies determine when Auto Scaling should increase or decrease the number of EC2 instances.

AWS supports multiple policy types.

---

## Dynamic Scaling

Automatically adjusts capacity based on CloudWatch metrics.

Example:

CPU Utilization > 70%

↓

Launch another EC2 instance

---

## Target Tracking Scaling

Maintains a predefined metric at a target value.

Example:

Target CPU = 50%

Auto Scaling automatically adjusts the number of instances to keep CPU utilization close to 50%.

---

## Scheduled Scaling

Changes capacity according to a predefined schedule.

Example:

Every weekday at 8:00 AM

↓

Increase Desired Capacity to 6

---

## Predictive Scaling

Uses machine learning to forecast future demand based on historical usage patterns.

This helps applications scale proactively before traffic increases.

---

# 9. Health Checks

Health Checks determine whether an EC2 instance is capable of serving requests.

Auto Scaling can use two different health sources.

---

## EC2 Health Checks

These verify the health of the virtual machine itself.

Examples of failures:

- Hardware failure
- Operating system crash
- Hypervisor issues

If the EC2 instance becomes unhealthy, Auto Scaling replaces it automatically.

---

## Elastic Load Balancer Health Checks

The Application Load Balancer periodically sends HTTP requests to each registered instance.

Example:

GET /

↓

HTTP 200 OK

↓

Healthy

If the application stops responding, the Target Group marks the instance as unhealthy and Auto Scaling replaces it if configured to do so.

---

## Why Both Health Checks Matter

Combining EC2 and ELB Health Checks provides a more complete view of system health.

- EC2 checks infrastructure availability.
- ELB checks application availability.

Together they improve reliability and reduce downtime.

---

# 10. Availability Zones

## What is an Availability Zone?

An Availability Zone (AZ) is one or more physically separate data centers within an AWS Region.

Each Availability Zone has independent:

- Power supply
- Cooling systems
- Physical security
- Network connectivity

Despite being isolated, Availability Zones are connected through high-speed, low-latency private networks, allowing applications to operate across multiple AZs with minimal communication delay.

---

## Why Deploy Across Multiple Availability Zones?

Deploying resources in multiple Availability Zones increases application resilience.

If one Availability Zone becomes unavailable due to infrastructure failures or maintenance events, workloads running in another Availability Zone can continue serving users.

Example:

```
Availability Zone A
    EC2 Instance 1
          │
          │
          ▼
Application Load Balancer
          ▲
          │
          │
Availability Zone B
    EC2 Instance 2
```

The Application Load Balancer distributes traffic between healthy instances in different Availability Zones.

---

## Benefits

- High Availability
- Fault Isolation
- Better Disaster Recovery
- Improved Reliability
- Increased Application Uptime

---

# 11. Load Balancer Integration

## Why Integrate Auto Scaling with an Application Load Balancer?

Without a Load Balancer, users would need to connect directly to individual EC2 instances.

This approach introduces several challenges:

- Uneven traffic distribution.
- Manual instance management.
- Single points of failure.
- Poor scalability.

The Application Load Balancer solves these problems by distributing incoming traffic across all healthy instances.

---

## Traffic Flow

```
Internet
    │
    ▼
Application Load Balancer
    │
    ▼
Target Group
    │
 ┌──┴──┐
 ▼     ▼
EC2   EC2
```

---

## Automatic Registration

One of the biggest advantages of integrating Auto Scaling with a Target Group is automatic registration.

Whenever Auto Scaling launches a new EC2 instance:

1. The instance starts.
2. User Data executes.
3. Apache starts.
4. Health Checks begin.
5. The instance is registered in the Target Group.
6. The Load Balancer starts routing traffic.

No manual intervention is required.

---

# 12. User Data

## What is User Data?

User Data is a bootstrap script executed automatically during the first startup of an EC2 instance.

It allows administrators to automate software installation and server configuration without manually connecting through SSH.

---

## Typical Tasks

User Data commonly performs:

- Operating system updates.
- Package installation.
- Web server installation.
- Configuration file creation.
- Service startup.
- Application deployment.

This enables Infrastructure Automation from the moment an instance is launched.

---

## Benefits

- Fully automated deployments.
- Consistent server configuration.
- Faster provisioning.
- Reduced human error.
- Repeatable infrastructure.

---

# 13. EC2 Instance Metadata Service (IMDSv2)

## What is IMDS?

The EC2 Instance Metadata Service provides information about the running EC2 instance.

Examples include:

- Instance ID
- Private IP
- Public IP
- Availability Zone
- Region
- IAM Role
- Security Credentials

Applications can retrieve this information without requiring AWS credentials.

---

## Why IMDSv2?

Earlier versions of the Metadata Service were vulnerable to certain attack scenarios.

IMDSv2 introduces session-based authentication using temporary tokens.

Advantages include:

- Better security.
- Protection against SSRF attacks.
- Token expiration.
- Improved access control.

AWS recommends using IMDSv2 for all new EC2 deployments.

---

## Metadata Examples

The following information can be retrieved:

| Metadata | Description |
|----------|-------------|
| instance-id | EC2 Instance Identifier |
| local-ipv4 | Private IP Address |
| hostname | Hostname |
| placement/availability-zone | Availability Zone |
| ami-id | Amazon Machine Image |
| instance-type | EC2 Instance Type |

---

# 14. Auto Scaling Lifecycle

Every EC2 instance managed by Auto Scaling follows a lifecycle.

```
Launch
   │
   ▼
Pending
   │
   ▼
InService
   │
   ▼
Healthy
   │
   ▼
Scale In / Scale Out
   │
   ▼
Terminating
   │
   ▼
Terminated
```

---

## Launch

Auto Scaling creates a new EC2 instance using the Launch Template.

---

## Pending

The instance is booting and User Data is executing.

---

## In Service

The instance passes Health Checks and begins receiving production traffic.

---

## Scale Out

Additional instances are launched when demand increases.

---

## Scale In

Extra instances are terminated when demand decreases.

---

## Termination

Instances leaving the Auto Scaling Group are gracefully terminated.

---

# 15. High Availability

## Definition

High Availability (HA) refers to designing systems that remain operational even when individual components fail.

AWS achieves High Availability through:

- Multiple Availability Zones.
- Load Balancers.
- Auto Scaling.
- Redundant infrastructure.

---

## High Availability in This Laboratory

This laboratory implements HA using:

- Two Availability Zones.
- Two EC2 Instances.
- Application Load Balancer.
- Auto Scaling Group.
- Target Group Health Checks.

If one EC2 instance fails, the remaining instance continues serving requests while Auto Scaling launches a replacement.

---

# 16. Fault Tolerance

Fault Tolerance is the ability of a system to continue operating despite failures.

Unlike basic High Availability, fault-tolerant systems are designed to tolerate failures without interrupting service.

Examples:

- EC2 instance crashes.
- Hardware failures.
- Operating system failures.
- Availability Zone outages.

Auto Scaling automatically replaces failed EC2 instances, minimizing downtime.

---

# 17. Horizontal vs Vertical Scaling

## Vertical Scaling

Increase the resources of an existing server.

Example:

```
t3.micro

↓

t3.large
```

Advantages:

- Simple implementation.
- No application changes.

Disadvantages:

- Hardware limits.
- Possible downtime.

---

## Horizontal Scaling

Increase the number of servers instead of increasing server size.

Example:

```
1 EC2

↓

2 EC2

↓

4 EC2
```

Advantages:

- Better availability.
- Fault tolerance.
- Unlimited growth potential.

Amazon EC2 Auto Scaling is based on Horizontal Scaling.

---

# 18. AWS Best Practices

AWS recommends the following practices when implementing Auto Scaling:

- Use Launch Templates instead of Launch Configurations.
- Enable IMDSv2.
- Deploy across multiple Availability Zones.
- Configure meaningful Health Checks.
- Integrate with Application Load Balancers.
- Monitor metrics using Amazon CloudWatch.
- Use least-privilege IAM roles.
- Automate deployments with User Data or configuration management tools.
- Tag resources consistently.
- Review scaling policies periodically.

---

# 19. Common Mistakes

Some common mistakes when working with Auto Scaling include:

- Setting an incorrect Desired Capacity.
- Forgetting to attach a Target Group.
- Misconfigured Security Groups.
- Health Check paths returning errors.
- User Data scripts containing syntax errors.
- Using outdated Launch Template versions.
- Not testing automatic instance replacement.

Understanding these issues helps reduce deployment failures.

---

# 20. Key Takeaways

After completing this laboratory you should understand:

- The purpose of Amazon EC2 Auto Scaling.
- The role of Launch Templates.
- How Auto Scaling Groups maintain infrastructure.
- The importance of Desired, Minimum and Maximum Capacity.
- How Health Checks improve reliability.
- Why Multi-AZ deployments increase availability.
- How User Data automates provisioning.
- Why IMDSv2 is recommended.
- The differences between High Availability and Fault Tolerance.
- When to use Horizontal Scaling instead of Vertical Scaling.

---

# 21. Glossary

| Term | Definition |
|------|------------|
| Auto Scaling | Automatic management of EC2 instances. |
| Launch Template | Reusable EC2 configuration template. |
| Desired Capacity | Target number of running EC2 instances. |
| Scale Out | Add new EC2 instances. |
| Scale In | Remove EC2 instances. |
| Target Group | Collection of backend instances for a Load Balancer. |
| Health Check | Verification that an instance is operating correctly. |
| Multi-AZ | Deployment across multiple Availability Zones. |
| IMDSv2 | Secure EC2 Instance Metadata Service. |
| User Data | Bootstrap script executed when an EC2 instance starts. |

---

# 22. Additional Reading

To deepen your understanding of Amazon EC2 Auto Scaling, consider exploring the following topics:

- Amazon CloudWatch Metrics and Alarms
- Step Scaling Policies
- Target Tracking Policies
- Predictive Scaling
- Lifecycle Hooks
- Warm Pools
- Mixed Instance Policies
- Spot Instances with Auto Scaling
- Auto Scaling Notifications
- AWS Well-Architected Framework – Reliability Pillar