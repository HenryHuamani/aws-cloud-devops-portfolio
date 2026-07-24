# Interview Questions

## Lab 06 – Amazon EC2 Auto Scaling

---

# Table of Contents

1. Junior Level
2. Mid-Level
3. Senior Level
4. Solutions Architect Level

---

# 1. Junior Level

## Question 1

### What is Amazon EC2 Auto Scaling?

**Answer**

Amazon EC2 Auto Scaling is an AWS service that automatically launches, replaces and terminates EC2 instances to maintain the desired number of healthy servers.

It helps applications remain available while reducing manual infrastructure management.

---

## Question 2

### Why is Auto Scaling important?

**Answer**

Auto Scaling provides:

- High Availability
- Automatic recovery
- Scalability
- Reduced operational effort
- Better resource utilization

Instead of manually creating EC2 instances, AWS automatically manages them.

---

## Question 3

### What is an Auto Scaling Group?

**Answer**

An Auto Scaling Group (ASG) is the logical component responsible for managing EC2 instances.

Its main responsibilities include:

- Launching instances
- Replacing unhealthy instances
- Maintaining desired capacity
- Integrating with Load Balancers

---

## Question 4

### What is a Launch Template?

**Answer**

A Launch Template is a reusable blueprint that defines how EC2 instances should be created.

It can include:

- AMI
- Instance Type
- Key Pair
- Security Groups
- User Data
- IAM Role
- Storage Configuration

---

## Question 5

### What is Desired Capacity?

**Answer**

Desired Capacity is the target number of EC2 instances that Auto Scaling tries to maintain.

Example:

Desired Capacity = 2

If only one instance remains healthy, Auto Scaling automatically launches another one.

---

## Question 6

### What is Minimum Capacity?

**Answer**

Minimum Capacity defines the smallest number of EC2 instances that must always remain running.

Auto Scaling will never scale below this value.

---

## Question 7

### What is Maximum Capacity?

**Answer**

Maximum Capacity defines the highest number of EC2 instances that Auto Scaling is allowed to create.

It prevents uncontrolled infrastructure growth.

---

## Question 8

### What is User Data?

**Answer**

User Data is a bootstrap script executed automatically during the first startup of an EC2 instance.

It is commonly used to:

- Install software
- Configure services
- Deploy applications
- Start web servers

---

## Question 9

### What is an Application Load Balancer?

**Answer**

An Application Load Balancer (ALB) distributes incoming HTTP and HTTPS traffic across multiple EC2 instances.

It improves:

- Availability
- Scalability
- Fault tolerance

---

## Question 10

### What is a Target Group?

**Answer**

A Target Group is a collection of backend resources that receive traffic from a Load Balancer.

The Target Group continuously monitors the health of registered instances.

Only healthy instances receive client requests.

---

## Question 11

### What is a Health Check?

**Answer**

A Health Check verifies whether an EC2 instance or application is functioning correctly.

If an instance becomes unhealthy, Auto Scaling can automatically replace it.

---

## Question 12

### What is an Availability Zone?

**Answer**

An Availability Zone is one or more isolated data centers within an AWS Region.

Deploying resources across multiple Availability Zones improves resilience and availability.

---

## Question 13

### Why is Multi-AZ deployment recommended?

**Answer**

Multi-AZ deployments reduce the impact of infrastructure failures.

If one Availability Zone becomes unavailable, instances in another zone continue serving traffic.

---

## Question 14

### What is Horizontal Scaling?

**Answer**

Horizontal Scaling increases capacity by adding more servers instead of increasing server size.

Amazon EC2 Auto Scaling uses Horizontal Scaling.

---

## Question 15

### What is Vertical Scaling?

**Answer**

Vertical Scaling increases the resources of an existing server, such as CPU or memory.

Example:

t3.micro

↓

t3.large

Unlike Horizontal Scaling, Vertical Scaling is limited by hardware capacity.

---

## Quick Interview Tips

When answering interview questions:

- Define the concept clearly.
- Explain why it is used.
- Mention a practical example.
- Highlight AWS best practices where applicable.

---

## Question 16

### What is a Scaling Policy?

**Answer**

A Scaling Policy defines the rules that determine when the Auto Scaling Group should add or remove EC2 instances.

Scaling Policies can respond to:

- CPU utilization
- Network traffic
- Memory utilization (using CloudWatch Agent)
- Custom CloudWatch metrics
- Scheduled events

---

## Question 17

### What is Amazon CloudWatch?

**Answer**

Amazon CloudWatch is AWS's monitoring and observability service.

It collects:

- Metrics
- Logs
- Events
- Alarms

CloudWatch provides the information Auto Scaling uses to make scaling decisions.

---

## Question 18

### What is Target Tracking Scaling?

**Answer**

Target Tracking Scaling automatically adjusts the number of EC2 instances to maintain a target metric.

Example:

Target CPU = 50%

If CPU rises above the target, Auto Scaling launches additional instances.

If CPU falls below the target, unnecessary instances may be terminated.

---

## Question 19

### What is Step Scaling?

**Answer**

Step Scaling increases or decreases capacity based on predefined metric ranges.

Example:

CPU > 60% → Add 1 instance

CPU > 80% → Add 2 instances

CPU > 90% → Add 3 instances

This provides more granular scaling behavior than Target Tracking.

---

## Question 20

### What is Scheduled Scaling?

**Answer**

Scheduled Scaling automatically changes the desired capacity at predefined dates and times.

Example:

Every weekday at 8:00 AM:

Desired Capacity = 6

Every weekday at 8:00 PM:

Desired Capacity = 2

It is useful for workloads with predictable traffic patterns.

---

## Question 21

### What happens if an EC2 instance fails?

**Answer**

If an EC2 instance becomes unhealthy:

1. Health Checks detect the failure.
2. Auto Scaling marks the instance as unhealthy.
3. The unhealthy instance is terminated.
4. A replacement instance is launched automatically using the Launch Template.
5. The new instance is registered with the Target Group.

This process is automatic and requires no manual intervention.

---

## Question 22

### Why are Health Checks important?

**Answer**

Health Checks ensure that only healthy EC2 instances receive client traffic.

Benefits include:

- Improved availability.
- Automatic recovery.
- Better user experience.
- Reduced downtime.

---

## Question 23

### What is IMDSv2?

**Answer**

IMDSv2 (Instance Metadata Service Version 2) is the secure version of the EC2 metadata service.

It requires temporary session tokens before metadata can be accessed.

Benefits include:

- Improved security.
- Protection against SSRF attacks.
- Temporary authentication tokens.
- AWS recommended best practice.

---

## Question 24

### What is a Security Group?

**Answer**

A Security Group is a virtual firewall that controls inbound and outbound traffic for AWS resources.

Rules specify:

- Protocol
- Port
- Source or destination

Example:

HTTP → Port 80

SSH → Port 22

---

## Question 25

### What is an IAM Role?

**Answer**

An IAM Role allows an AWS service to securely access other AWS resources without embedding long-term credentials.

For EC2 instances, IAM Roles can grant permissions such as:

- Reading objects from Amazon S3.
- Sending logs to CloudWatch.
- Accessing AWS Systems Manager.

---

## Question 26

### What is the difference between Launch Templates and Launch Configurations?

**Answer**

Launch Templates are the modern and recommended method for defining EC2 launch settings.

Compared to Launch Configurations, Launch Templates support:

- Versioning.
- More EC2 features.
- Flexible networking.
- Latest AWS capabilities.

AWS recommends using Launch Templates for all new deployments.

---

## Question 27

### Why should User Data be automated?

**Answer**

Automating server configuration through User Data provides:

- Consistent deployments.
- Faster provisioning.
- Reduced manual work.
- Lower risk of configuration errors.

It also supports Infrastructure as Code practices.

---

## Question 28

### Why is an Application Load Balancer used with Auto Scaling?

**Answer**

The Application Load Balancer distributes incoming traffic across healthy EC2 instances managed by the Auto Scaling Group.

This provides:

- Better scalability.
- High Availability.
- Fault tolerance.
- Even traffic distribution.

---

## Question 29

### What is High Availability?

**Answer**

High Availability is the practice of designing systems that continue operating despite component failures.

In AWS, High Availability is commonly achieved through:

- Multiple Availability Zones.
- Load Balancers.
- Auto Scaling Groups.
- Redundant infrastructure.

---

## Question 30

### What is Fault Tolerance?

**Answer**

Fault Tolerance is the ability of a system to continue operating even when one or more components fail.

Auto Scaling contributes to fault tolerance by automatically replacing failed EC2 instances and maintaining the desired application capacity.

---

# Junior Level Summary

A candidate should understand the following concepts before moving to intermediate-level topics:

- Amazon EC2 Auto Scaling
- Launch Templates
- Auto Scaling Groups
- Desired, Minimum and Maximum Capacity
- Scaling Policies
- CloudWatch
- Target Groups
- Application Load Balancers
- Health Checks
- User Data
- IMDSv2
- Security Groups
- IAM Roles
- High Availability
- Fault Tolerance

# 2. Mid-Level

---

## Question 31

### What is the difference between Desired Capacity and Current Capacity?

**Answer**

Desired Capacity is the target number of EC2 instances that the Auto Scaling Group attempts to maintain.

Current Capacity represents the actual number of running EC2 instances at a given moment.

Example:

Desired Capacity = 4

Current Capacity = 3

↓

Auto Scaling automatically launches one additional instance.

---

## Question 32

### What happens if Desired Capacity is changed manually?

**Answer**

When Desired Capacity is modified, the Auto Scaling Group immediately reconciles the infrastructure.

If Desired Capacity increases:

- New EC2 instances are launched.

If Desired Capacity decreases:

- Extra EC2 instances are terminated according to the termination policy.

---

## Question 33

### What are Lifecycle Hooks?

**Answer**

Lifecycle Hooks allow custom actions to be executed when an EC2 instance is launching or terminating.

Examples include:

- Installing additional software.
- Running configuration scripts.
- Registering the instance in external systems.
- Backing up logs before termination.

Lifecycle Hooks provide greater control over the Auto Scaling lifecycle.

---

## Question 34

### What is a Warm Pool?

**Answer**

A Warm Pool is a group of pre-initialized EC2 instances maintained in a stopped or running state.

When demand increases, Auto Scaling can start these prepared instances much faster than launching new ones from scratch.

Benefits:

- Faster scaling.
- Reduced application startup time.
- Better user experience during traffic spikes.

---

## Question 35

### What is the difference between Dynamic Scaling and Scheduled Scaling?

**Answer**

Dynamic Scaling reacts to CloudWatch metrics such as CPU utilization.

Scheduled Scaling changes capacity based on predefined schedules.

Example:

Dynamic Scaling:

CPU > 70%

↓

Launch another EC2 instance.

Scheduled Scaling:

Every Monday at 08:00

↓

Desired Capacity = 6

---

## Question 36

### What is Scale Out?

**Answer**

Scale Out is the process of adding additional EC2 instances to increase application capacity.

Example:

```
2 EC2

↓

4 EC2
```

Scale Out is typically triggered by increased demand or CloudWatch alarms.

---

## Question 37

### What is Scale In?

**Answer**

Scale In removes unnecessary EC2 instances when demand decreases.

This reduces infrastructure costs while maintaining application availability.

Example:

```
6 EC2

↓

3 EC2
```

---

## Question 38

### Why is CloudWatch required for Auto Scaling?

**Answer**

CloudWatch continuously monitors infrastructure metrics such as:

- CPU Utilization
- Network Traffic
- Disk Activity
- Memory Usage (with CloudWatch Agent)

Auto Scaling uses these metrics to determine when scaling actions should occur.

---

## Question 39

### What metrics are commonly used for Auto Scaling?

**Answer**

Common metrics include:

- CPU Utilization
- Request Count
- Network In
- Network Out
- ALB Request Count Per Target
- Memory Utilization (CloudWatch Agent)
- Custom Application Metrics

---

## Question 40

### What happens if a Health Check fails?

**Answer**

If a Health Check fails:

1. The instance is marked as unhealthy.
2. Traffic is stopped.
3. Auto Scaling terminates the instance.
4. A replacement instance is launched.
5. The new instance is registered with the Target Group.

This process minimizes downtime.

---

## Question 41

### What is an AMI?

**Answer**

An Amazon Machine Image (AMI) is a template used to create EC2 instances.

It contains:

- Operating System
- Installed Software
- Configuration
- Storage Mapping

Launch Templates reference an AMI whenever new instances are launched.

---

## Question 42

### Why should Launch Templates be versioned?

**Answer**

Versioning allows infrastructure changes to be tracked and rolled back if necessary.

Example:

Version 1

↓

Apache only

Version 2

↓

Apache + Docker

If Version 2 introduces issues, Auto Scaling can immediately return to Version 1.

---

## Question 43

### What is a Target Group Health Check Path?

**Answer**

The Health Check Path specifies the URL used by the Application Load Balancer to verify application health.

Examples:

```
/
```

```
/health
```

```
/status
```

The application must return an HTTP 200 response for the target to be considered healthy.

---

## Question 44

### Why should applications expose a dedicated Health Check endpoint?

**Answer**

Dedicated Health Check endpoints provide a lightweight method for verifying application health.

Benefits:

- Faster validation.
- Reduced server load.
- More accurate health monitoring.
- Better troubleshooting.

---

## Question 45

### What is Instance Refresh?

**Answer**

Instance Refresh is an Auto Scaling feature that gradually replaces existing EC2 instances with new ones using an updated Launch Template.

It enables rolling updates with minimal service disruption.

---

## Question 46

### What is Connection Draining (Deregistration Delay)?

**Answer**

Connection Draining allows existing client connections to complete before an EC2 instance is removed from service.

This prevents interrupted user requests during Scale In operations.

---

## Question 47

### Why are Security Groups important in Auto Scaling?

**Answer**

Every EC2 instance launched by Auto Scaling inherits the Security Groups defined in the Launch Template.

Consistent Security Groups ensure:

- Standard firewall rules.
- Secure communication.
- Simplified management.

---

## Question 48

### What happens if User Data contains an error?

**Answer**

The EC2 instance may launch successfully, but the application might not be configured correctly.

Examples:

- Apache not installed.
- Services not started.
- Missing configuration files.
- Failed application deployment.

Logs such as `/var/log/cloud-init-output.log` should be reviewed for troubleshooting.

---

## Question 49

### Why is IMDSv2 recommended instead of IMDSv1?

**Answer**

IMDSv2 introduces session-based authentication using temporary tokens.

Advantages include:

- Improved security.
- Protection against SSRF attacks.
- Better control over metadata access.

AWS recommends IMDSv2 for all new EC2 deployments.

---

## Question 50

### How does Auto Scaling improve cost optimization?

**Answer**

Auto Scaling launches additional instances only when demand requires them and removes unnecessary instances when demand decreases.

Benefits include:

- Lower operational costs.
- Efficient resource utilization.
- Reduced overprovisioning.
- Improved scalability.

---

# Mid-Level Summary

A mid-level AWS engineer should understand:

- Scaling Policies.
- CloudWatch Metrics.
- Lifecycle Hooks.
- Warm Pools.
- Instance Refresh.
- Health Check Paths.
- Connection Draining.
- IMDSv2.
- Rolling Updates.
- Cost Optimization strategies.

---

## Question 51

### An EC2 instance was terminated unexpectedly. What will Auto Scaling do?

**Answer**

If the terminated instance belonged to an Auto Scaling Group:

1. Auto Scaling detects that the current capacity is below the desired capacity.
2. A new EC2 instance is launched using the Launch Template.
3. User Data executes automatically.
4. Health Checks are performed.
5. The new instance is registered in the Target Group.
6. The Application Load Balancer begins routing traffic to the new instance.

No manual intervention is required.

---

## Question 52

### Users report that the website is unavailable, but the EC2 instances are running. What would you check first?

**Answer**

Possible causes include:

- Target Group Health Checks are failing.
- Apache service is stopped.
- Security Group rules are blocking HTTP traffic.
- User Data failed during instance initialization.
- Application is not listening on port 80.
- Application Load Balancer Listener is misconfigured.

The first step is to verify the Target Group Health Status.

---

## Question 53

### How would you troubleshoot an Unhealthy Target in an Application Load Balancer?

**Answer**

Typical troubleshooting steps include:

1. Verify the Health Check Path.
2. Confirm the application returns HTTP 200.
3. Ensure Apache (or the web server) is running.
4. Check Security Group rules.
5. Review EC2 system logs.
6. Review cloud-init logs.
7. Test the application locally using:

```bash
curl localhost
```

Only after identifying the root cause should corrective actions be applied.

---

## Question 54

### Auto Scaling is not launching additional EC2 instances. What could be the reason?

**Answer**

Possible causes include:

- Maximum Capacity has already been reached.
- Scaling Policy is not configured correctly.
- CloudWatch Alarm is not triggering.
- Launch Template contains invalid settings.
- Insufficient AWS service quotas.
- IAM permissions are missing.

Each of these components should be verified systematically.

---

## Question 55

### Why might an EC2 instance continuously fail Health Checks?

**Answer**

Common reasons include:

- Web server is not running.
- Wrong Health Check Path.
- Firewall or Security Group restrictions.
- Application startup failure.
- User Data execution errors.
- Port mismatch.

Checking application logs and Health Check configuration usually identifies the problem.

---

## Question 56

### How would you safely update the configuration of every EC2 instance?

**Answer**

Recommended approach:

1. Create a new Launch Template version.
2. Test the new configuration.
3. Perform an Instance Refresh.
4. Monitor Health Checks.
5. Verify application functionality.

This minimizes downtime and ensures a controlled rollout.

---

## Question 57

### Why shouldn't administrators manually modify Auto Scaling EC2 instances?

**Answer**

Because Auto Scaling instances are considered disposable.

Any manual changes will be lost when the instance is replaced.

Instead:

- Update the Launch Template.
- Update User Data.
- Use configuration management tools.
- Redeploy through Auto Scaling.

This follows immutable infrastructure principles.

---

## Question 58

### How can Auto Scaling improve application availability?

**Answer**

Auto Scaling continuously maintains healthy EC2 instances.

If one instance fails:

- Traffic is redirected.
- A replacement instance is launched.
- Desired Capacity is restored.

Users experience little or no service interruption.

---

## Question 59

### Why is User Data preferred over manual server configuration?

**Answer**

User Data ensures:

- Consistent deployments.
- Faster provisioning.
- Reduced configuration drift.
- Fully automated infrastructure.

It also supports Infrastructure as Code practices.

---

## Question 60

### In which scenarios would you recommend Amazon EC2 Auto Scaling?

**Answer**

Auto Scaling is recommended for:

- Public web applications.
- APIs.
- Microservices.
- E-commerce platforms.
- Enterprise portals.
- Applications with variable traffic.
- Systems requiring High Availability.

It is especially valuable when workloads fluctuate throughout the day.

---

# Mid-Level Summary

A mid-level engineer should be able to:

- Configure Auto Scaling Groups.
- Troubleshoot unhealthy instances.
- Understand scaling policies.
- Diagnose Health Check failures.
- Explain Launch Templates.
- Automate infrastructure with User Data.
- Integrate Auto Scaling with Application Load Balancers.
- Optimize cost while maintaining availability.
- Perform rolling updates using Instance Refresh.
- Apply AWS operational best practices.

# 3. Senior Level

---

## Question 61

### A web application experiences traffic spikes every Friday evening. How would you design the Auto Scaling strategy?

**Answer**

I would combine multiple scaling strategies:

- Scheduled Scaling to increase capacity before the expected traffic spike.
- Target Tracking Scaling to automatically adjust capacity based on CPU utilization or ALB Request Count.
- Minimum Capacity configured to guarantee baseline availability.
- Maximum Capacity configured according to expected peak demand.

This hybrid approach provides predictable scaling while still adapting to unexpected traffic variations.

---

## Question 62

### Your application must remain available if an entire Availability Zone fails. How would you design the infrastructure?

**Answer**

I would deploy the application using:

- An Application Load Balancer.
- Multiple public or private subnets.
- EC2 instances distributed across at least two Availability Zones.
- An Auto Scaling Group spanning all Availability Zones.
- Health Checks enabled.
- Amazon RDS Multi-AZ for the database layer.

This architecture eliminates a single point of failure and improves overall resilience.

---

## Question 63

### CPU utilization remains below 20%, but operational costs are high. What would you review?

**Answer**

I would analyze:

- Desired Capacity.
- Minimum Capacity.
- Maximum Capacity.
- Instance Type.
- CloudWatch metrics.
- Traffic patterns.
- Scaling Policies.

If resources are consistently underutilized, I would reduce the minimum capacity or select a smaller instance type.

---

## Question 64

### Auto Scaling continuously launches and terminates instances. What might be happening?

**Answer**

This behavior is commonly known as **scaling flapping**.

Possible causes include:

- Aggressive scaling thresholds.
- Health Check failures.
- Incorrect cooldown periods.
- Misconfigured CloudWatch alarms.
- Application startup time longer than expected.

I would review scaling policies and adjust thresholds and cooldown settings.

---

## Question 65

### How would you perform a zero-downtime deployment?

**Answer**

A recommended approach is:

1. Create a new Launch Template version.
2. Perform an Instance Refresh.
3. Replace instances gradually.
4. Verify Health Checks.
5. Monitor application metrics.
6. Roll back if issues are detected.

This minimizes service disruption during deployments.

---

## Question 66

### What is immutable infrastructure?

**Answer**

Immutable infrastructure is the practice of replacing servers instead of modifying them.

If a configuration change is required:

- Create a new Launch Template version.
- Launch new instances.
- Remove the old instances.

This reduces configuration drift and improves consistency.

---

## Question 67

### How would you monitor an Auto Scaling environment in production?

**Answer**

I would use:

- Amazon CloudWatch Metrics.
- CloudWatch Alarms.
- CloudWatch Dashboards.
- AWS CloudTrail.
- Amazon SNS notifications.
- AWS Systems Manager.
- Application logs.

Monitoring should include both infrastructure and application metrics.

---

## Question 68

### What metrics would you monitor?

**Answer**

Important metrics include:

Infrastructure:

- CPU Utilization
- Network In
- Network Out
- Status Check Failed

Application:

- Request Count
- Target Response Time
- HTTP 5XX Errors
- HTTP 4XX Errors

Auto Scaling:

- Group Desired Capacity
- Group InService Instances
- Group Pending Instances
- Group Terminating Instances

---

## Question 69

### How would you investigate frequent Auto Scaling replacements?

**Answer**

Investigation steps:

1. Review Target Group Health Checks.
2. Check Apache or application logs.
3. Verify User Data execution.
4. Review CloudWatch metrics.
5. Analyze Auto Scaling Activity History.
6. Confirm Launch Template configuration.
7. Validate Security Group rules.

Always identify the root cause before replacing infrastructure.

---

## Question 70

### Why is designing for failure important?

**Answer**

Failures are inevitable.

Good cloud architectures assume that:

- Servers fail.
- Networks fail.
- Availability Zones fail.

Instead of trying to prevent every failure, systems should recover automatically with minimal user impact.

This principle is central to the AWS Well-Architected Framework.

---

## Question 71

### How would you reduce recovery time after an EC2 failure?

**Answer**

Recovery can be improved by:

- Using Auto Scaling Groups.
- Automating configuration with User Data.
- Storing configuration in Launch Templates.
- Monitoring with CloudWatch.
- Keeping AMIs updated.

Automation significantly reduces recovery time.

---

## Question 72

### What is the difference between scalability and elasticity?

**Answer**

Scalability is the ability of a system to handle increased workload.

Elasticity is the ability to automatically increase and decrease resources according to demand.

Auto Scaling provides elasticity.

---

## Question 73

### How would you secure an Auto Scaling environment?

**Answer**

Recommended practices include:

- Enable IMDSv2.
- Apply least-privilege IAM roles.
- Restrict Security Group rules.
- Use encrypted EBS volumes.
- Enable CloudTrail logging.
- Patch operating systems regularly.
- Store secrets securely using AWS Secrets Manager.

---

## Question 74

### What AWS Well-Architected pillars are applied in this laboratory?

**Answer**

The laboratory demonstrates several pillars:

- Operational Excellence.
- Security.
- Reliability.
- Performance Efficiency.
- Cost Optimization.

Each design decision supports one or more of these principles.

---

## Question 75

### Why is automation essential in cloud environments?

**Answer**

Automation provides:

- Faster deployments.
- Consistent infrastructure.
- Reduced human error.
- Better scalability.
- Improved operational efficiency.

It also supports Infrastructure as Code and DevOps practices.

---

# Senior Level Summary

A senior engineer should be able to:

- Design resilient cloud architectures.
- Optimize cost without sacrificing availability.
- Monitor production environments effectively.
- Automate deployments.
- Troubleshoot complex failures.
- Apply AWS Well-Architected Framework principles.
- Justify architectural decisions based on business and technical requirements.

---

## Question 76

### Your application experiences sudden traffic spikes after a marketing campaign. How would you prepare the infrastructure?

**Answer**

I would implement a combination of proactive and reactive scaling strategies.

The architecture would include:

- Application Load Balancer
- Auto Scaling Group
- Target Tracking Scaling Policy
- CloudWatch Alarms
- Multi-AZ deployment
- Warm Pool (optional)

I would also:

- Increase Maximum Capacity.
- Configure Scheduled Scaling before the campaign.
- Monitor CPU, Request Count and Target Response Time.
- Validate Health Checks.
- Perform load testing before production.

This approach minimizes the risk of service degradation during high-demand periods.

---

## Question 77

### How would you minimize deployment risks when updating an application?

**Answer**

I would follow these steps:

1. Create a new Launch Template version.
2. Validate the configuration in a test environment.
3. Perform an Instance Refresh.
4. Monitor CloudWatch metrics.
5. Verify ALB Health Checks.
6. Confirm application functionality.
7. Roll back if abnormal behavior is detected.

Using rolling updates reduces downtime and limits the impact of configuration errors.

---

## Question 78

### Your application startup takes five minutes, but Health Checks fail after one minute. What would you do?

**Answer**

The Health Check configuration should be adjusted to match the application's startup time.

Possible changes include:

- Increase Health Check Grace Period.
- Increase Healthy Threshold.
- Increase Timeout.
- Increase Interval.
- Delay Health Check execution until the application is fully initialized.

Failing to adjust these values may cause Auto Scaling to continuously replace healthy instances before they finish starting.

---

## Question 79

### Why should applications be stateless in an Auto Scaling environment?

**Answer**

Auto Scaling frequently creates and terminates EC2 instances.

If application data is stored locally on the instance:

- Data may be lost.
- User sessions may disappear.
- Scaling becomes difficult.

Stateless applications store persistent information in external services such as:

- Amazon RDS
- Amazon ElastiCache
- Amazon S3
- Amazon DynamoDB

This allows any EC2 instance to process any request.

---

## Question 80

### How would you troubleshoot intermittent application failures?

**Answer**

I would investigate in the following order:

1. CloudWatch Metrics.
2. Auto Scaling Activity History.
3. ALB Target Health.
4. EC2 System Status Checks.
5. Application Logs.
6. Cloud-init Logs.
7. Network Connectivity.
8. Security Groups.
9. Recent Launch Template changes.

The objective is to isolate whether the issue is related to infrastructure, networking or the application itself.

---

## Question 81

### What risks exist if Auto Scaling is configured with an incorrect Maximum Capacity?

**Answer**

If Maximum Capacity is too low:

- The application may become overloaded.
- User requests may fail.
- Response times may increase.

If Maximum Capacity is too high:

- Infrastructure costs may increase unnecessarily.
- Resource quotas may be exceeded.
- Scaling events may become difficult to control.

Capacity planning should always be based on expected workload and historical metrics.

---

## Question 82

### How would you optimize infrastructure costs while maintaining High Availability?

**Answer**

Possible strategies include:

- Right-size EC2 instances.
- Configure appropriate Minimum Capacity.
- Use Auto Scaling.
- Purchase Savings Plans or Reserved Instances for baseline capacity.
- Use Spot Instances for fault-tolerant workloads.
- Continuously monitor utilization with CloudWatch.

The goal is to balance cost, performance and availability.

---

## Question 83

### What information would you collect before investigating an Auto Scaling incident?

**Answer**

I would collect:

- Auto Scaling Activity History.
- CloudWatch Metrics.
- CloudWatch Alarms.
- Target Group Health Status.
- Application Logs.
- EC2 System Logs.
- Launch Template Version.
- Recent infrastructure changes.
- IAM events through CloudTrail.

This information provides the context needed to identify the root cause efficiently.

---

## Question 84

### What would happen if the Launch Template references an invalid AMI?

**Answer**

Auto Scaling would attempt to launch new instances, but the requests would fail.

Possible consequences include:

- Desired Capacity would not be achieved.
- Auto Scaling Activity History would report launch failures.
- The application might become unavailable if existing instances fail.

Validating Launch Template changes before deployment is essential.

---

## Question 85

### What are the characteristics of a well-designed Auto Scaling architecture?

**Answer**

A production-ready Auto Scaling architecture should include:

- Multiple Availability Zones.
- Application Load Balancer.
- Target Groups.
- Health Checks.
- Launch Templates.
- CloudWatch monitoring.
- Secure IAM Roles.
- Proper Security Groups.
- Automated provisioning through User Data.
- Infrastructure automation.
- Continuous monitoring.
- Well-defined scaling policies.

Such an architecture provides high availability, scalability, resilience and operational efficiency.

# 4. Solutions Architect Level

---

## Question 86

### Design a highly available web application architecture for millions of users.

**Answer**

A recommended architecture would include:

```
Users
    │
    ▼
Amazon Route 53
    │
    ▼
AWS WAF
    │
    ▼
Application Load Balancer
    │
    ▼
Auto Scaling Group
    │
 ┌──┴────────────┐
 ▼               ▼
Availability   Availability
Zone A         Zone B
 │               │
 ▼               ▼
EC2            EC2
 │               │
 └──────┬────────┘
        ▼
Amazon RDS Multi-AZ
        │
        ▼
Amazon S3
```

This architecture provides:

- High Availability
- Scalability
- Fault Tolerance
- Security
- Elasticity

---

## Question 87

### When would you choose Auto Scaling instead of manually launching EC2 instances?

**Answer**

Auto Scaling should be used when:

- Application traffic changes over time.
- High Availability is required.
- Automatic recovery is desired.
- Operational effort should be minimized.
- Infrastructure needs to scale automatically.

Manual EC2 provisioning is only appropriate for:

- Development environments.
- Temporary workloads.
- Small proof-of-concept projects.

---

## Question 88

### When would you choose Amazon ECS instead of EC2 Auto Scaling?

**Answer**

Amazon ECS is preferred when applications are containerized.

Choose ECS when:

- Running Docker containers.
- Deploying microservices.
- Managing multiple application versions.
- Simplifying deployments.

Choose EC2 Auto Scaling when:

- Running traditional virtual machines.
- Hosting legacy applications.
- Full operating system control is required.

---

## Question 89

### When would you choose Amazon EKS instead of ECS?

**Answer**

Amazon EKS is recommended when:

- Kubernetes expertise already exists.
- Multi-cloud portability is required.
- Complex container orchestration is needed.
- Organizations have standardized on Kubernetes.

Amazon ECS is generally simpler and requires less operational overhead.

---

## Question 90

### Your application must survive the failure of an entire AWS Region. How would you design it?

**Answer**

A Multi-Region architecture would include:

- Route 53 Failover Routing.
- Two AWS Regions.
- Independent Auto Scaling Groups.
- Independent Application Load Balancers.
- Database replication.
- Amazon S3 Cross-Region Replication.
- Continuous monitoring.

This approach improves disaster recovery capabilities.

---

## Question 91

### How would you design for cost optimization while maintaining High Availability?

**Answer**

Recommended practices include:

- Auto Scaling.
- Savings Plans.
- Reserved Instances for baseline capacity.
- Spot Instances for non-critical workloads.
- Right-sized EC2 instances.
- CloudWatch monitoring.
- Scheduled Scaling.

Cost optimization should never compromise business availability requirements.

---

## Question 92

### How would you secure an internet-facing Auto Scaling application?

**Answer**

Recommended architecture:

Users

↓

AWS Shield

↓

AWS WAF

↓

Application Load Balancer

↓

Auto Scaling Group

↓

Private Database

Security recommendations:

- HTTPS only.
- AWS Certificate Manager.
- IAM Roles.
- IMDSv2.
- Encrypted EBS.
- Secrets Manager.
- Least privilege access.

---

## Question 93

### Which AWS Well-Architected pillars are demonstrated by this laboratory?

**Answer**

This laboratory demonstrates:

Operational Excellence

- Automated deployments.
- Launch Templates.
- User Data.

Security

- Security Groups.
- IAM Roles.
- IMDSv2.

Reliability

- Auto Scaling.
- Multi-AZ.
- Health Checks.

Performance Efficiency

- Load Balancer.
- Elastic infrastructure.

Cost Optimization

- Automatic Scale In.
- Resource optimization.

---

## Question 94

### What improvements would you implement before moving this laboratory to production?

**Answer**

Production improvements include:

- HTTPS.
- AWS Certificate Manager.
- Route 53.
- Amazon RDS.
- AWS Backup.
- CloudWatch Alarms.
- CloudTrail.
- AWS Config.
- AWS Systems Manager.
- Amazon SNS notifications.
- Infrastructure as Code using Terraform.

---

## Question 95

### How would you explain Auto Scaling to a non-technical stakeholder?

**Answer**

Imagine a restaurant.

When only a few customers arrive, two waiters are enough.

As more customers arrive, additional waiters are called in automatically.

When the restaurant becomes less busy, the extra waiters leave.

Auto Scaling works in the same way.

Instead of waiters, AWS automatically adds or removes servers according to customer demand.

This improves customer experience while controlling operational costs.

---

## Question 96

### What are the main trade-offs of using Auto Scaling?

**Answer**

Advantages:

- High Availability.
- Automatic recovery.
- Cost optimization.
- Elasticity.
- Reduced manual effort.

Disadvantages:

- Increased architectural complexity.
- Requires monitoring.
- Scaling policies must be tuned.
- Application should be stateless.
- Startup time can affect scaling responsiveness.

---

## Question 97

### How does this laboratory align with Infrastructure as Code principles?

**Answer**

Although the infrastructure was created manually using the AWS Console, it follows Infrastructure as Code concepts by:

- Standardizing configuration through Launch Templates.
- Automating provisioning with User Data.
- Maintaining reproducible infrastructure.
- Eliminating manual server configuration.

Future versions can replace manual configuration with Terraform or AWS CloudFormation.

---

## Question 98

### If you had to evolve this laboratory into an enterprise platform, what services would you add?

**Answer**

Recommended services include:

- Amazon RDS.
- Amazon ElastiCache.
- Amazon EFS.
- Amazon CloudFront.
- AWS WAF.
- AWS Shield.
- Route 53.
- CloudWatch.
- CloudTrail.
- AWS Config.
- Secrets Manager.
- Amazon SNS.
- Amazon SQS.
- AWS Systems Manager.
- Terraform.
- GitHub Actions.

This would transform the laboratory into a production-ready platform.

---

## Question 99

### What were the key architectural decisions made in this laboratory?

**Answer**

Key decisions included:

- Using Launch Templates for standardization.
- Deploying Auto Scaling across multiple Availability Zones.
- Integrating with an Application Load Balancer.
- Enabling Health Checks.
- Automating provisioning with User Data.
- Using IMDSv2.
- Designing for High Availability and Fault Tolerance.

These choices improve scalability, reliability and operational efficiency.

---

## Question 100

### What are the most important lessons learned from this laboratory?

**Answer**

The main lessons include:

- Auto Scaling automates EC2 lifecycle management.
- Launch Templates ensure consistent deployments.
- User Data enables repeatable provisioning.
- Health Checks are essential for reliability.
- Multi-AZ deployments improve availability.
- Application Load Balancers distribute traffic efficiently.
- CloudWatch enables intelligent scaling.
- IMDSv2 strengthens security.
- Stateless application design simplifies scaling.
- Automation is fundamental to modern cloud architectures.

Completing this laboratory establishes a strong foundation for more advanced AWS services such as Amazon RDS, Amazon ECS, Amazon EKS, Terraform and CI/CD pipelines.