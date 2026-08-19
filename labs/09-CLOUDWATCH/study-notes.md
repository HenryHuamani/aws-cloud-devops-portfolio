# Study Notes – Lab 09

> **Lab:** Lab 09 – Amazon CloudWatch Monitoring, Alarms & Auto Scaling Validation  
> **Environment:** NovaCommerce  
> **Region:** `us-east-2`  
> **Status:** ✅ Completed

---

# 1. Laboratory Goal

Lab 09 integrates the main NovaCommerce infrastructure components into a highly available, scalable, self-healing, and monitored AWS architecture.

The solution combines:

- Amazon VPC
- Amazon EC2
- EC2 Launch Templates
- EC2 Auto Scaling
- Application Load Balancer
- Amazon EFS
- Amazon RDS
- Amazon CloudWatch
- Amazon SNS
- Security Groups
- Network ACLs

The key idea is that the application must not depend on a single EC2 instance.

Instead, AWS distributes application capacity across multiple Availability Zones and automatically reacts to changes in workload and instance health.

---

# 2. Final Architecture

High-level application flow:

```text
Internet Users
      │
      ▼
Internet Gateway
      │
      ▼
Application Load Balancer
portfolio-alb
      │
      ▼
Target Group
portfolio-web-tg
      │
      ▼
Auto Scaling Group
portfolio-asg
      │
      ├────────────────┐
      ▼                ▼
EC2 Instance       EC2 Instance
us-east-2a         us-east-2b
      │                │
      └────────┬───────┘
               │
        ┌──────┴──────┐
        ▼             ▼
   Amazon EFS     Amazon RDS
 Shared Storage   Private MySQL
```

Monitoring flow:

```text
AWS Resources
     │
     ▼
Amazon CloudWatch
     │
     ├── Metrics
     ├── Dashboard
     └── Alarms
          │
          ▼
      Amazon SNS
          │
          ▼
     Notifications
```

---

# 3. Key Architecture Values

```text
Region:
us-east-2

VPC:
portfolio-vpc

VPC CIDR:
10.0.0.0/16

Availability Zones:
us-east-2a
us-east-2b

Application Load Balancer:
portfolio-alb

Target Group:
portfolio-web-tg

Auto Scaling Group:
portfolio-asg

Launch Template:
portfolio-web-template

Web Security Group:
web-sg

EFS:
novacommerce-efs

EFS Security Group:
portfolio-efs-sg

RDS:
portfolio-db

RDS Security Group:
portfolio-rds-sg
```

---

# 4. High Availability

High availability means designing the application so that the failure of an individual resource does not necessarily cause the complete service to become unavailable.

The laboratory applies high availability through:

- Multiple EC2 instances.
- Multiple Availability Zones.
- Application Load Balancer.
- Target Group Health Checks.
- Auto Scaling instance replacement.
- Regional Amazon EFS with Mount Targets in multiple AZs.

Important concept:

```text
One EC2 instance = potential single point of failure

Multiple EC2 instances + ALB + Multi-AZ = more resilient architecture
```

---

# 5. Availability Zones

The application tier uses:

```text
us-east-2a
us-east-2b
```

An Availability Zone is an isolated location within an AWS Region.

Using multiple AZs reduces dependency on a single Availability Zone.

The Auto Scaling Group distributes capacity across the configured subnets/AZs.

---

# 6. Amazon VPC

Amazon VPC provides the isolated network environment for NovaCommerce.

Laboratory VPC:

```text
portfolio-vpc
10.0.0.0/16
```

The architecture uses public and private network segments.

Key components include:

- VPC
- Subnets
- Route Tables
- Internet Gateway
- Network ACLs
- Security Groups

---

# 7. Public vs Private Subnets

## Public Subnet

A public subnet has a route that allows Internet-bound traffic to reach an Internet Gateway.

Example:

```text
0.0.0.0/0 → Internet Gateway
```

## Private Subnet

A private subnet does not have a direct route to an Internet Gateway.

The distinction is primarily determined by routing, not by the subnet name.

Important interview point:

> A subnet is not public simply because it is called "public". Its route table and resource configuration determine its connectivity.

---

# 8. Internet Gateway

The Internet Gateway provides connectivity between the VPC and the Internet when routing and resource configuration permit it.

The public route table was validated with:

```text
0.0.0.0/0 → Internet Gateway
```

---

# 9. Security Groups

Security Groups are stateful virtual firewalls associated with AWS resources/network interfaces.

Stateful means response traffic for an allowed connection is automatically permitted.

The laboratory uses different Security Groups for different responsibilities.

---

# 10. Web Security Group

The web tier allows:

```text
HTTP
TCP 80
```

Administrative SSH access uses:

```text
SSH
TCP 22
```

and is restricted to trusted administrative IP addresses.

Security principle:

```text
Do not expose SSH 22 to 0.0.0.0/0 unless absolutely required.
```

---

# 11. EFS Security Group

Amazon EFS uses NFS.

Required port:

```text
TCP 2049
```

The EFS Security Group controls which resources can establish NFS connectivity to the filesystem.

---

# 12. RDS Security Group

Amazon RDS MySQL uses:

```text
TCP 3306
```

Instead of allowing:

```text
0.0.0.0/0
```

the database Security Group permits access from the authorized web/application Security Group.

This is an example of least privilege and tier-to-tier Security Group referencing.

---

# 13. Security Groups vs Network ACLs

## Security Group

```text
Level: Resource / ENI
Stateful: Yes
Allow rules: Yes
Explicit deny rules: No
```

## Network ACL

```text
Level: Subnet
Stateful: No
Allow rules: Yes
Deny rules: Yes
```

Because NACLs are stateless, inbound and outbound traffic must both be considered.

---

# 14. EC2 Launch Template

Launch Template:

```text
portfolio-web-template
```

A Launch Template provides a reusable definition for EC2 instances.

It can contain:

- AMI
- Instance type
- Security Groups
- Key pair
- User Data
- Metadata options
- Storage configuration

The Auto Scaling Group uses the Launch Template whenever it needs to create a new EC2 instance.

---

# 15. Why Launch Templates Matter

Without a standardized template, automatically created instances could have inconsistent configuration.

With a Launch Template:

```text
Auto Scaling
     │
     ▼
Launch Template
     │
     ▼
Consistently configured EC2
```

This is especially important during:

- Scale-out.
- Automatic replacement.
- Recovery from failures.

---

# 16. EC2 User Data

User Data automates configuration when an EC2 instance launches.

In the laboratory, User Data performs tasks such as:

- System update.
- Apache installation.
- Apache enablement.
- Apache startup.
- Instance metadata retrieval.
- Generation of the validation web page.

This reduces manual configuration.

---

# 17. IMDSv2

IMDSv2 stands for EC2 Instance Metadata Service Version 2.

It uses a token before allowing metadata requests.

The laboratory retrieves:

```text
Instance ID
Availability Zone
Private IPv4
```

These values are displayed on the web page.

Why?

Because when requests are sent through the ALB, the page identifies which backend EC2 instance processed the request.

---

# 18. Apache

Apache HTTP Server runs on the application EC2 instances.

Main service:

```text
httpd
```

Useful commands:

```bash
sudo systemctl status httpd
sudo systemctl start httpd
sudo systemctl stop httpd
sudo systemctl restart httpd
```

Application validation:

```bash
curl -I http://localhost/
```

Expected response:

```text
HTTP/1.1 200 OK
```

---

# 19. Application Load Balancer

ALB:

```text
portfolio-alb
```

The Application Load Balancer provides a common entry point for web traffic.

Traffic flow:

```text
Client
   │
   ▼
ALB
   │
   ▼
Target Group
   │
   ▼
Healthy EC2 target
```

The ALB prevents users from needing to connect directly to a specific EC2 instance.

---

# 20. ALB Listener

The laboratory uses:

```text
Protocol: HTTP
Port: 80
```

The listener receives client traffic and forwards requests according to configured rules.

---

# 21. Target Group

Target Group:

```text
portfolio-web-tg
```

The Target Group contains the application backends used by the ALB.

In this architecture, EC2 instances created and managed by the Auto Scaling Group become backend targets.

---

# 22. Health Checks

The Target Group uses application Health Checks.

Configuration:

```text
Protocol: HTTP
Path: /
Port: Traffic Port
Healthy Threshold: 5
Unhealthy Threshold: 2
Timeout: 5 seconds
Interval: 30 seconds
Success Code: 200
```

Meaning:

- AWS sends HTTP requests to `/`.
- A successful application response should return code `200`.
- Repeated failures cause the target to become unhealthy.
- Repeated successes return the target to healthy status.

---

# 23. Why Health Checks Matter

An EC2 instance can be technically running while the application itself is unavailable.

For example:

```text
EC2 state: running
Apache: stopped
Application: unavailable
```

An application-level ALB Health Check can detect this condition.

This is more useful than relying only on the EC2 power state.

---

# 24. Auto Scaling Group

ASG:

```text
portfolio-asg
```

Capacity configuration:

```text
Minimum: 2
Desired: 2
Maximum: 4
```

Meaning:

## Minimum

The group should not intentionally scale below:

```text
2
```

## Desired

The group attempts to maintain:

```text
2
```

under baseline conditions.

## Maximum

The group cannot scale beyond:

```text
4
```

during this laboratory.

---

# 25. Why Minimum Capacity = 2

A minimum of two EC2 instances avoids a baseline architecture that depends on a single web server.

When distributed correctly across Availability Zones, it supports application resilience.

---

# 26. Target Tracking

Scaling policy:

```text
portfolio-asg-cpu-target-tracking
```

Configuration:

```text
Metric:
Average CPU Utilization

Target:
50%

Instance Warmup:
300 seconds

Scale In:
Enabled
```

Target Tracking attempts to maintain the selected metric near the configured target.

---

# 27. Scale-Out

Scale-out means adding compute capacity.

The laboratory validated:

```text
2 EC2
   │
   ▼
CPU stress
   │
   ▼
CPU increases
   │
   ▼
Target Tracking reacts
   │
   ▼
Desired capacity increases
   │
   ▼
4 EC2
```

This proves horizontal elasticity.

---

# 28. CPU Stress Test

`stress-ng` was used to intentionally increase CPU utilization in a controlled laboratory environment.

Example:

```bash
stress-ng --cpu 2 --timeout 600s
```

The objective was not to benchmark the server.

The objective was to create enough sustained CPU load for the Target Tracking policy to react.

---

# 29. Why Scaling Is Not Instantaneous

Auto Scaling depends on metrics and policy evaluation.

Factors include:

- CloudWatch metric collection.
- Alarm evaluation.
- Instance warmup.
- Stabilization behavior.
- EC2 launch time.
- Target registration.
- Health Check convergence.

Therefore:

```text
High CPU ≠ immediate new EC2 instance
```

Some delay is expected.

---

# 30. Scale-In

Scale-in means removing unnecessary compute capacity.

The laboratory validated:

```text
4 EC2
   │
   ▼
CPU stress stops
   │
   ▼
CPU decreases
   │
   ▼
Scaling policy evaluates demand
   │
   ▼
Excess capacity removed
   │
   ▼
Baseline capacity restored
```

---

# 31. Important Scale-In Lesson

During validation, capacity should not be manually reduced.

If the administrator manually changes desired capacity from 4 to 2, the test no longer proves automatic scale-in.

Correct validation:

```text
Stop workload
      ↓
Wait
      ↓
Observe metrics
      ↓
Allow Target Tracking to act
      ↓
Confirm automatic scale-in
```

---

# 32. Self-Healing

Auto Scaling is not only about adding or removing capacity.

It can also restore unhealthy capacity.

Validated sequence:

```text
Application failure
      │
      ▼
Target becomes unhealthy
      │
      ▼
Failure detected
      │
      ▼
Unhealthy instance replaced
      │
      ▼
New EC2 launched
      │
      ▼
Application initializes
      │
      ▼
Target becomes healthy
```

This is one of the most important reliability concepts demonstrated in the laboratory.

---

# 33. Elasticity vs Self-Healing

These concepts should not be confused.

## Elasticity

Changes capacity because workload changes.

Example:

```text
2 → 4 → 2
```

## Self-Healing

Restores capacity because a resource becomes unhealthy.

Example:

```text
Failed EC2 → Replacement EC2
```

Both were validated.

---

# 34. Amazon EFS

EFS:

```text
novacommerce-efs
```

Amazon EFS provides shared filesystem storage.

Unlike instance-local files, EFS can be accessed by multiple EC2 instances.

---

# 35. Why Shared Storage Matters with Auto Scaling

Auto Scaling instances are disposable.

An instance may be:

- Created.
- Replaced.
- Terminated.
- Scaled in.

Therefore, application data that must be shared should not depend exclusively on one instance's local filesystem.

EFS provides:

```text
EC2 A ──┐
        ├── Amazon EFS
EC2 B ──┘
```

---

# 36. EFS Multi-AZ Design

The laboratory validated EFS Mount Targets in:

```text
us-east-2a
us-east-2b
```

This aligns EFS network access with the Multi-AZ application architecture.

---

# 37. EFS Security

EFS configuration included:

```text
Encryption: Enabled
Automatic Backups: Enabled
Protocol: NFS
Port: TCP 2049
```

A dedicated Security Group protects NFS connectivity.

---

# 38. Amazon RDS

RDS database:

```text
portfolio-db
```

Engine:

```text
MySQL
```

Database port:

```text
TCP 3306
```

RDS provides a managed relational database layer.

---

# 39. Private RDS

A critical security configuration validated in the laboratory was:

```text
Publicly accessible: No
```

The database does not need arbitrary direct Internet access.

Application-to-database traffic should remain controlled through the VPC and Security Groups.

---

# 40. Why RDS Should Not Be Open to 0.0.0.0/0

Opening MySQL port 3306 to the entire Internet unnecessarily increases exposure.

Better:

```text
Web/Application Security Group
            │
            ▼
       TCP 3306
            │
            ▼
      RDS Security Group
```

This implements a more restrictive access model.

---

# 41. RDS Backups and Monitoring

The laboratory reviewed:

- Automated backups.
- Backup configuration.
- Maintenance configuration.
- RDS monitoring metrics.

Managed database services reduce some of the operational work associated with running databases directly on EC2.

---

# 42. Amazon CloudWatch

CloudWatch provides monitoring and observability.

The laboratory monitored indicators including:

- EC2 CPU utilization.
- ALB requests.
- Healthy Host Count.
- Target Response Time.
- Auto Scaling behavior.

---

# 43. CloudWatch Metrics

A metric is a time-ordered set of datapoints representing resource behavior.

Example:

```text
EC2 CPUUtilization
```

Metrics are the basis for:

- Graphs.
- Dashboards.
- Alarms.
- Scaling decisions.

---

# 44. CloudWatch Alarms

An alarm evaluates a metric against defined conditions.

Possible states include:

```text
OK
ALARM
INSUFFICIENT_DATA
```

During the laboratory, alarm transitions were observed during controlled load and failure tests.

---

# 45. CloudWatch Dashboard

A centralized dashboard was used to view important infrastructure indicators together.

This reduces the need to navigate separately through every AWS resource.

Dashboard value:

```text
One view
   │
   ├── CPU
   ├── Requests
   ├── Healthy Hosts
   └── Response Time
```

---

# 46. Auto Scaling Metrics – Important Lesson

During the laboratory, some Auto Scaling graphs initially displayed:

```text
No data available
```

The issue was related to Auto Scaling group metrics collection/data availability.

After the relevant metrics were enabled and CloudWatch received datapoints, the graphs became available.

Lesson:

> EC2 instance monitoring and Auto Scaling group monitoring are related but not identical.

---

# 47. Amazon SNS

Amazon SNS was integrated with CloudWatch alarms.

Purpose:

```text
CloudWatch Alarm
       │
       ▼
     SNS
       │
       ▼
Notification
```

This provides operational awareness without requiring an administrator to continuously watch the AWS console.

---

# 48. Final Load Balancing Validation

One of the strongest laboratory validations showed requests reaching different EC2 instances through the same ALB.

The application displayed:

```text
Instance ID
Availability Zone
Private IP
Shared Storage
```

Requests were served by EC2 instances in different Availability Zones.

This demonstrates actual application behavior rather than only static configuration.

---

# 49. What the Final Validation Proves

The final Multi-AZ application test proves several concepts simultaneously:

- The ALB is reachable.
- The listener works.
- The Target Group works.
- Multiple EC2 instances are healthy.
- Traffic reaches different backends.
- The application runs in multiple AZs.
- Auto Scaling instances are serving traffic.
- The application identifies EFS shared storage.

This is stronger evidence than simply showing the ALB configuration page.

---

# 50. Most Important Laboratory Lifecycle

Remember this sequence:

```text
BASELINE
2 EC2 Instances
      │
      ▼
LOAD TEST
CPU increases
      │
      ▼
MONITORING
CloudWatch detects demand
      │
      ▼
ELASTICITY
Scale-out
      │
      ▼
4 EC2 Instances
      │
      ▼
RECOVERY
CPU decreases
      │
      ▼
ELASTICITY
Scale-in
      │
      ▼
2 EC2 Instances
```

Separate reliability test:

```text
Healthy EC2
     │
     ▼
Application Failure
     │
     ▼
Unhealthy Target
     │
     ▼
Auto Scaling Replacement
     │
     ▼
New Healthy EC2
```

---

# 51. Core Concepts to Explain in an Interview

Be able to explain clearly:

1. Why the architecture uses multiple AZs.
2. Why an ALB is used.
3. What a Target Group does.
4. How Health Checks work.
5. Why Auto Scaling uses minimum, desired, and maximum capacity.
6. How Target Tracking works.
7. Difference between scale-out and scale-in.
8. Difference between elasticity and self-healing.
9. Why a Launch Template is required.
10. Why User Data is useful.
11. Why EFS is useful with Auto Scaling.
12. Why RDS is private.
13. Why Security Group references are useful.
14. Difference between Security Groups and NACLs.
15. What CloudWatch monitors.
16. Why SNS notifications matter.

---

# 52. Quick Revision Sheet

```text
VPC
portfolio-vpc
10.0.0.0/16

AZs
us-east-2a
us-east-2b

ALB
portfolio-alb
HTTP :80

Target Group
portfolio-web-tg

Health Check
HTTP /
200
Healthy: 5
Unhealthy: 2
Timeout: 5s
Interval: 30s

ASG
portfolio-asg
Min: 2
Desired: 2
Max: 4

Scaling
Average CPU
Target: 50%
Warmup: 300s

Launch Template
portfolio-web-template
t3.micro

EFS
novacommerce-efs
NFS TCP 2049
Encrypted
Multi-AZ Mount Targets

RDS
portfolio-db
MySQL
TCP 3306
Not publicly accessible

Monitoring
CloudWatch

Notifications
SNS
```

---

# 53. Common Mistakes to Avoid

## Mistake 1

Assuming an EC2 instance being `running` means the application is healthy.

Correct concept:

```text
EC2 running ≠ application healthy
```

Use application Health Checks.

## Mistake 2

Opening database port 3306 to the Internet.

Use restricted Security Group access.

## Mistake 3

Manually changing desired capacity during an automatic scaling test.

This invalidates the scaling validation.

## Mistake 4

Expecting Auto Scaling to react instantly.

CloudWatch evaluation, warmup, launch time, and stabilization introduce expected delay.

## Mistake 5

Storing required shared application data only on local EC2 storage.

Auto Scaling instances are replaceable.

Use persistent/shared services where appropriate.

## Mistake 6

Taking screenshots of every AWS console tab.

Evidence should demonstrate a technical requirement or validation result, not simply document every available console screen.

---

# 54. AWS Well-Architected Mapping

## Reliability

Demonstrated by:

- Multi-AZ deployment.
- ALB Health Checks.
- Auto Scaling.
- Automatic instance replacement.
- Shared managed storage.

## Security

Demonstrated by:

- Security Groups.
- Restricted SSH.
- EFS Security Group.
- Private RDS.
- Restricted MySQL access.
- EFS encryption.
- Network isolation.

## Performance Efficiency

Demonstrated by:

- Horizontal scaling.
- Target Tracking.
- Load balancing.

## Operational Excellence

Demonstrated by:

- CloudWatch.
- Dashboards.
- Alarms.
- SNS.
- Controlled testing.
- Troubleshooting documentation.

---

# 55. Final Takeaways

The most important lesson from Lab 09 is that high availability is not achieved by one AWS service.

It is the result of several components working together:

```text
Networking
   +
Load Balancing
   +
Multiple EC2 Instances
   +
Auto Scaling
   +
Health Checks
   +
Shared Storage
   +
Private Database
   +
Monitoring
   +
Notifications
```

The laboratory demonstrated not only how these components are configured, but also how they behave during:

- Increased CPU demand.
- Capacity expansion.
- Capacity reduction.
- Application failure.
- Automatic replacement.
- Multi-AZ traffic distribution.

That operational validation is what turns the architecture from a static AWS configuration into a tested resilient system.

---

# Related Repository Files

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

**Lab Status:** ✅ Completed
