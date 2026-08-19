# Interview Questions – Lab 09

This file contains technical interview questions and model answers based on the architecture implemented and validated in Lab 09 – Amazon CloudWatch Monitoring, Alarms & Auto Scaling Validation.

The questions focus on the AWS services, design decisions, troubleshooting scenarios, and validation activities demonstrated in the NovaCommerce environment.

---

# 1. Architecture and High Availability

## Q1. What was the main objective of Lab 09?

The objective was to implement and validate a highly available, scalable, resilient, and monitored web architecture for NovaCommerce.

The solution integrates:

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

The architecture distributes workloads across multiple Availability Zones and automatically reacts to changes in demand and instance health.

---

## Q2. Why were multiple Availability Zones used?

Multiple Availability Zones reduce the risk of a single infrastructure location becoming a single point of failure.

In this laboratory, the application tier was distributed across:

```text
us-east-2a
us-east-2b
```

This allows the Application Load Balancer and Auto Scaling Group to distribute application capacity across separate Availability Zones.

---

## Q3. What is the difference between high availability and scalability?

High availability focuses on keeping the application accessible when individual resources fail.

Scalability focuses on adjusting capacity according to workload demand.

In this laboratory:

- Multi-AZ deployment and automatic instance replacement demonstrate high availability.
- Auto Scaling scale-out and scale-in demonstrate scalability.

---

## Q4. What does Multi-AZ mean in this architecture?

It means that application resources are distributed across more than one AWS Availability Zone.

The Auto Scaling Group can maintain EC2 instances in both `us-east-2a` and `us-east-2b`, while the Application Load Balancer distributes traffic across healthy targets.

---

# 2. Amazon VPC and Networking

## Q5. What is the purpose of Amazon VPC?

Amazon VPC provides an isolated virtual network in AWS where resources such as EC2, load balancers, EFS, and RDS can be deployed.

The laboratory uses:

```text
portfolio-vpc
CIDR: 10.0.0.0/16
```

---

## Q6. Why use public and private subnets?

Public and private subnets separate resources according to their connectivity requirements.

Public-facing components require routing that can reach an Internet Gateway.

Private resources should not receive direct inbound Internet connectivity unless there is a specific requirement.

This separation reduces unnecessary exposure.

---

## Q7. What makes a subnet public?

A subnet is considered public when its route table contains a route to an Internet Gateway and resources are configured appropriately for Internet connectivity.

The laboratory validated a route similar to:

```text
0.0.0.0/0 → Internet Gateway
```

---

## Q8. What is the role of the Internet Gateway?

An Internet Gateway provides a path between a VPC and the Internet for resources whose routing and addressing configuration permit Internet communication.

---

## Q9. What is the difference between a Security Group and a Network ACL?

A Security Group operates at the resource or network-interface level and is stateful.

A Network ACL operates at the subnet level and is stateless.

Because NACLs are stateless, inbound and outbound traffic must be considered independently.

---

# 3. Security Groups

## Q10. What traffic was allowed to the web tier?

The web Security Group allowed HTTP traffic on:

```text
TCP 80
```

SSH administration on:

```text
TCP 22
```

was restricted to trusted administrative IP addresses instead of being opened universally.

---

## Q11. How was EFS access protected?

Amazon EFS used a dedicated Security Group.

NFS traffic was allowed through:

```text
TCP 2049
```

This limits EFS connectivity to the resources that require shared filesystem access.

---

## Q12. How was RDS protected?

The RDS database was configured as not publicly accessible.

Its Security Group allowed MySQL connectivity through:

```text
TCP 3306
```

from the authorized application Security Group.

This is preferable to exposing the database port to `0.0.0.0/0`.

---

## Q13. Why is referencing another Security Group useful?

Security Group references allow access to be based on resource membership rather than fixed IP addresses.

This is especially useful with Auto Scaling because EC2 instances can be created and terminated dynamically.

---

# 4. EC2 Launch Templates

## Q14. What is an EC2 Launch Template?

A Launch Template defines reusable EC2 configuration that can be used when launching instances.

It can contain information such as:

- AMI
- Instance type
- Security Groups
- Key pair
- User Data
- Other instance settings

In this laboratory, the Auto Scaling Group used:

```text
portfolio-web-template
```

---

## Q15. Why is a Launch Template important for Auto Scaling?

Auto Scaling must be able to create replacement or additional EC2 instances automatically.

The Launch Template ensures new instances are created using a consistent configuration.

---

## Q16. What was User Data used for?

User Data automated initial server configuration.

The laboratory used it to perform tasks such as:

- Updating the operating system
- Installing Apache
- Enabling Apache
- Starting Apache
- Retrieving EC2 metadata
- Generating the web validation page

---

## Q17. What is IMDSv2?

IMDSv2 is version 2 of the EC2 Instance Metadata Service.

It uses a session-oriented token mechanism before metadata can be requested.

The laboratory used instance metadata to retrieve:

- Instance ID
- Availability Zone
- Private IP address

These values were displayed by the application to help validate load balancing.

---

# 5. Application Load Balancer

## Q18. What is the purpose of an Application Load Balancer?

An Application Load Balancer receives application traffic and distributes requests across healthy backend targets.

In this laboratory:

```text
Internet
   ↓
portfolio-alb
   ↓
portfolio-web-tg
   ↓
EC2 instances
```

---

## Q19. On which port did the ALB receive application traffic?

The laboratory configured an HTTP listener on:

```text
TCP 80
```

---

## Q20. What is a Target Group?

A Target Group is a logical collection of backend targets to which the load balancer forwards traffic.

The laboratory used:

```text
portfolio-web-tg
```

with EC2 instances managed by the Auto Scaling Group.

---

## Q21. How does the ALB know whether an EC2 instance is healthy?

The Target Group performs Health Checks.

The laboratory used:

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

---

## Q22. What happens when a target becomes unhealthy?

The load balancer stops routing normal application traffic to a target that fails its health requirements.

Combined with Auto Scaling health management, this can contribute to automatic replacement and recovery of failed application capacity.

---

# 6. EC2 Auto Scaling

## Q23. What is an Auto Scaling Group?

An Auto Scaling Group manages a collection of EC2 instances and maintains capacity according to configured minimum, desired, and maximum values.

The laboratory used:

```text
Minimum: 2
Desired: 2
Maximum: 4
```

---

## Q24. Why was the minimum capacity set to 2?

A minimum of two instances helps avoid depending on a single application server and supports Multi-AZ availability when capacity is appropriately distributed.

---

## Q25. What is desired capacity?

Desired capacity is the number of instances the Auto Scaling Group attempts to maintain at a given time.

A scaling policy can modify desired capacity automatically.

---

## Q26. What is maximum capacity?

Maximum capacity defines the upper limit on the number of instances that the Auto Scaling Group can launch.

In the laboratory:

```text
Maximum Capacity: 4
```

This prevented the controlled stress test from scaling indefinitely.

---

# 7. Target Tracking and CPU Scaling

## Q27. What scaling policy was implemented?

A Target Tracking policy based on average CPU utilization.

The target was approximately:

```text
50%
```

---

## Q28. How does Target Tracking work?

Target Tracking attempts to keep a selected metric close to a configured target value.

If average CPU utilization remains above the target, Auto Scaling can add capacity.

When demand decreases sufficiently, the policy can remove unnecessary capacity while respecting stabilization behavior and capacity limits.

---

## Q29. What was the scale-out test?

CPU load was generated on the application instances using `stress-ng`.

The validation sequence was:

```text
2 instances
   ↓
CPU stress
   ↓
CPU utilization increases
   ↓
Target Tracking reacts
   ↓
Scale-out
   ↓
4 instances
```

---

## Q30. What is scale-out?

Scale-out means adding additional compute instances to increase horizontal capacity.

The laboratory validated an increase from:

```text
2 → 4 EC2 instances
```

---

## Q31. What is scale-in?

Scale-in means reducing horizontal compute capacity when additional instances are no longer required.

After the stress workload ended and CPU utilization decreased, Auto Scaling reduced capacity toward the baseline.

---

## Q32. Why did scale-in not happen immediately?

Target Tracking and Auto Scaling include stabilization behavior designed to prevent rapid capacity changes caused by short-lived metric fluctuations.

CloudWatch also requires metric datapoints before alarm conditions and scaling decisions can be evaluated.

---

## Q33. Why should desired capacity not be manually changed during the scale-in test?

Because manually reducing desired capacity would no longer prove that the scaling policy performed the scale-in automatically.

For a valid test, the system must be allowed to react without manual capacity intervention.

---

# 8. Self-Healing

## Q34. What does self-healing mean in this architecture?

Self-healing means the infrastructure can detect unhealthy application capacity and restore the required capacity automatically.

The laboratory validated:

```text
Unhealthy target
      ↓
Failure detection
      ↓
Instance replacement
      ↓
New instance
      ↓
Healthy target
```

---

## Q35. Why is automatic instance replacement important?

Without automatic replacement, an administrator may need to manually identify and rebuild failed application servers.

Auto Scaling reduces this operational dependency by maintaining the configured application capacity.

---

# 9. Amazon EFS

## Q36. What is Amazon EFS?

Amazon Elastic File System is a managed shared filesystem service.

Multiple EC2 instances can access the same filesystem, making it useful when application servers need shared files.

---

## Q37. Why was EFS useful in the NovaCommerce architecture?

Auto Scaling instances are dynamic.

If important application files existed only on an individual EC2 instance, replacing that instance could make those local files unavailable.

EFS provides shared storage that can be accessed by multiple application instances.

---

## Q38. Which protocol does EFS use?

The laboratory used NFS connectivity through:

```text
TCP 2049
```

---

## Q39. Why were EFS Mount Targets configured in multiple Availability Zones?

Mount Targets provide network access to EFS from the VPC.

Deploying them across the Availability Zones used by the application supports the Multi-AZ design and provides local EFS access paths for those zones.

---

# 10. Amazon RDS

## Q40. Why use Amazon RDS instead of installing MySQL directly on EC2?

Amazon RDS is a managed relational database service.

It reduces operational work associated with database infrastructure and provides managed capabilities such as backups, maintenance, and monitoring.

---

## Q41. Why was the database configured as not publicly accessible?

The application tier should access the database internally.

There was no requirement for arbitrary Internet clients to connect directly to MySQL.

Removing public exposure reduces the attack surface.

---

## Q42. Which database port was used?

MySQL uses:

```text
TCP 3306
```

---

## Q43. What security principle is demonstrated by allowing port 3306 from the web Security Group instead of from the entire Internet?

Least privilege.

Only the application resources that require database access should be permitted to connect.

---

# 11. Amazon CloudWatch

## Q44. What was CloudWatch used for?

CloudWatch provided observability for the architecture.

The laboratory monitored metrics such as:

- EC2 CPU utilization
- ALB request activity
- Healthy Host Count
- Target Response Time
- Auto Scaling-related metrics and alarms

---

## Q45. What is a CloudWatch Alarm?

A CloudWatch Alarm evaluates a metric against configured conditions.

When the alarm state changes, it can provide operational visibility and integrate with services such as Amazon SNS.

---

## Q46. Why did some Auto Scaling graphs initially display "No data available"?

Auto Scaling group metrics collection had not yet been enabled or sufficient datapoints were not yet available.

After enabling the required metrics and allowing CloudWatch to receive datapoints, monitoring information became available.

---

## Q47. Why is a CloudWatch Dashboard useful?

A dashboard provides a centralized view of multiple infrastructure metrics.

Instead of checking each AWS resource independently, an operator can monitor important indicators from one location.

---

# 12. Amazon SNS

## Q48. What role did Amazon SNS play?

Amazon SNS provided operational notifications associated with CloudWatch alarm events.

This allowed monitoring events to be communicated outside the CloudWatch console.

---

## Q49. Why are notifications important in production environments?

Administrators cannot continuously watch dashboards.

Notifications allow important infrastructure events to be surfaced when attention may be required.

---

# 13. Troubleshooting Scenarios

## Q50. CPU is high, but the ASG has not scaled yet. What would you check?

I would check:

1. The Target Tracking policy.
2. The selected metric.
3. The target value.
4. CloudWatch datapoints.
5. Alarm state.
6. Instance warmup.
7. ASG minimum, desired, and maximum capacity.
8. Whether the CPU load lasted long enough.
9. Auto Scaling Activity History.

---

## Q51. An ALB target is unhealthy. What would you check?

I would verify:

1. Target Group Health Check protocol.
2. Health Check path.
3. Health Check port.
4. Application service status.
5. Apache status.
6. Security Group rules.
7. Whether the application returns the expected HTTP success code.
8. Target Group health reason.
9. EC2 instance health.

Useful commands include:

```bash
sudo systemctl status httpd
curl -I http://localhost/
sudo ss -tulpn | grep ':80'
```

---

## Q52. EFS cannot be mounted. What would you check?

I would verify:

1. EFS Mount Targets.
2. Availability Zone and subnet configuration.
3. EFS Security Group.
4. NFS TCP port 2049.
5. EC2 Security Group connectivity.
6. EFS/NFS utilities.
7. Mount command and mount directory.
8. VPC network connectivity.

---

## Q53. The application cannot connect to RDS. What would you check?

I would verify:

1. RDS status.
2. RDS endpoint.
3. Database port 3306.
4. `portfolio-rds-sg`.
5. Source Security Group.
6. Subnet/network routing.
7. Database credentials.
8. Application database configuration.

The database should not be made publicly accessible merely to solve an internal connectivity problem.

---

# 14. Architecture Design Questions

## Q54. Why is the ALB preferable to giving users the public IP address of a single EC2 instance?

A single EC2 address creates dependency on one backend server.

The ALB provides a stable application entry point and can distribute traffic across multiple healthy EC2 targets.

---

## Q55. Why should application state not depend exclusively on local EC2 storage in an Auto Scaling architecture?

Auto Scaling instances can be replaced at any time.

Data stored only on one instance can disappear from the application's perspective when that instance is terminated.

Shared or managed persistent services such as EFS and RDS help separate application state from individual compute instances.

---

## Q56. What AWS Well-Architected concepts are demonstrated by this laboratory?

The laboratory demonstrates concepts associated with several AWS Well-Architected pillars:

### Reliability

- Multi-AZ architecture
- Health Checks
- Automatic replacement
- Auto Scaling

### Performance Efficiency

- Dynamic horizontal scaling
- Load balancing

### Security

- Security Groups
- Network isolation
- Private RDS
- Restricted database connectivity
- EFS encryption

### Operational Excellence

- CloudWatch monitoring
- Dashboards
- Alarm notifications
- Controlled testing and troubleshooting

---

# 15. Scenario Questions

## Q57. Traffic suddenly doubles. What should happen in this architecture?

If the increased workload causes average CPU utilization to remain above the configured Target Tracking target, Auto Scaling should increase application capacity, subject to the configured maximum.

The ALB then distributes requests across the healthy targets.

---

## Q58. One EC2 instance fails while two instances are running. What should happen?

The unhealthy application target should be detected.

Auto Scaling should restore the required capacity by launching a replacement instance, and the Target Group should eventually return to a healthy state.

---

## Q59. CPU utilization falls after a traffic spike. What should happen?

The Target Tracking policy should eventually remove excess capacity after the relevant metric and stabilization conditions are satisfied.

The ASG should not remain permanently overprovisioned when the additional capacity is no longer required.

---

## Q60. Why was a maximum of four instances useful in this laboratory?

It provided a controlled upper scaling boundary.

This allowed the scale-out test to demonstrate elasticity without allowing the laboratory workload to create unlimited EC2 capacity.

---

# 16. Short Interview Summary

A concise explanation of the project could be:

> I implemented a highly available NovaCommerce web architecture on AWS using an Application Load Balancer and an EC2 Auto Scaling Group distributed across two Availability Zones. I used a Launch Template with User Data to automate Apache provisioning, configured CPU Target Tracking to scale from a baseline of two instances up to four, and validated both automatic scale-out and scale-in using controlled CPU stress. I also tested automatic replacement of unhealthy instances. Amazon EFS provided shared storage, Amazon RDS provided a private MySQL database, and CloudWatch with SNS provided centralized monitoring and notifications. The final validation confirmed that the ALB distributed requests across EC2 instances in different Availability Zones.

---

# 17. Key Numbers to Remember

```text
AWS Region: us-east-2

VPC CIDR:
10.0.0.0/16

Availability Zones:
us-east-2a
us-east-2b

ALB Listener:
HTTP / TCP 80

Target Group Health Check:
HTTP /
Success Code: 200
Healthy Threshold: 5
Unhealthy Threshold: 2
Timeout: 5 seconds
Interval: 30 seconds

Auto Scaling:
Minimum: 2
Desired: 2
Maximum: 4

Target Tracking:
Average CPU Utilization
Target: 50%
Instance Warmup: 300 seconds

EFS:
NFS / TCP 2049

RDS MySQL:
TCP 3306
Public Access: Disabled
```

---

# 18. Services to Remember

```text
portfolio-vpc
portfolio-alb
portfolio-web-tg
portfolio-asg
portfolio-web-template
web-sg
novacommerce-efs
portfolio-efs-sg
portfolio-db
portfolio-rds-sg
portfolio-monitoring-dashboard
```

---

**Lab Status:** ✅ Completed
