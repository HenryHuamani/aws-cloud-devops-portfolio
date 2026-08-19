# Troubleshooting – Lab 09

> **Lab:** Lab 09 – Amazon CloudWatch Monitoring, Alarms & Auto Scaling Validation  
> **Environment:** NovaCommerce  
> **Region:** `us-east-2`  
> **Status:** ✅ Completed

---

# Overview

This document records the main troubleshooting scenarios encountered or deliberately tested during Lab 09.

The purpose is not only to document the final working architecture, but also to demonstrate how problems were identified, validated, and resolved during the implementation of:

- Application Load Balancer
- Target Groups and Health Checks
- EC2 Auto Scaling
- Target Tracking
- Amazon EFS
- Amazon RDS
- Amazon CloudWatch
- Amazon SNS
- VPC networking and Security Groups

Each issue is documented using:

```text
Problem
Root Cause
Diagnosis
Resolution
Validation
Lessons Learned
```

---

# Issue 1 – Auto Scaling Monitoring Displayed "No data available"

## Problem

During validation of the Auto Scaling Group, some monitoring graphs initially displayed:

```text
No data available
```

This made it difficult to verify Auto Scaling Group behavior from the monitoring view.

## Root Cause

The required Auto Scaling Group metrics were not yet available for the selected monitoring view.

Metric collection and CloudWatch datapoint availability must be considered separately from basic EC2 instance monitoring.

## Diagnosis

The Auto Scaling monitoring section was reviewed and the absence of datapoints was confirmed.

The investigation focused on:

- Auto Scaling Group monitoring.
- CloudWatch metric availability.
- Metric collection status.
- Time required for new datapoints to appear.

## Resolution

Auto Scaling Group metrics collection was enabled where required.

The environment was then left running long enough for CloudWatch to receive and display new datapoints.

## Validation

After the required metrics became available, Auto Scaling monitoring graphs displayed data and could be used during the scaling tests.

## Lessons Learned

EC2 metrics and Auto Scaling Group metrics are not exactly the same monitoring layer.

When a graph displays:

```text
No data available
```

verify metric collection and allow sufficient time for CloudWatch datapoints before assuming the infrastructure is incorrectly configured.

---

# Issue 2 – Scale-Out Did Not Happen Immediately

## Problem

CPU load was generated on the EC2 application instances, but additional instances did not appear immediately.

## Root Cause

Target Tracking does not react instantaneously.

Several steps occur before new capacity becomes available:

```text
CPU Load
   ↓
CloudWatch Metric Collection
   ↓
Policy Evaluation
   ↓
Scaling Decision
   ↓
EC2 Launch
   ↓
Instance Warmup
   ↓
Target Registration
   ↓
Health Check
```

## Diagnosis

The following were reviewed:

- CPU utilization.
- Target Tracking policy.
- Target value.
- Auto Scaling Activity History.
- Current desired capacity.
- Maximum capacity.
- Instance warmup.
- Target Group health.

## Resolution

The CPU workload was maintained long enough for CloudWatch and the Target Tracking policy to evaluate sustained demand.

No manual scale-out was performed.

## Validation

The Auto Scaling Group automatically increased capacity from:

```text
2 → 4 EC2 instances
```

The additional instances were launched and registered with the application infrastructure.

## Lessons Learned

Auto Scaling tests require patience.

A valid test should allow AWS to perform the complete scaling lifecycle instead of manually modifying desired capacity when the response is not immediate.

---

# Issue 3 – Scale-In Did Not Happen Immediately

## Problem

After the CPU stress test ended, the Auto Scaling Group temporarily remained at four instances.

It initially appeared that scale-in was not working.

## Root Cause

Target Tracking includes conservative scale-in and stabilization behavior to prevent premature removal of capacity.

CPU utilization must remain sufficiently low and the scaling system must evaluate the new workload state before excess capacity is removed.

## Diagnosis

The following were monitored:

- EC2 CPU utilization.
- CloudWatch alarm state.
- Auto Scaling Activity History.
- Desired capacity.
- Number of running instances.
- Scaling policy behavior.

## Resolution

The CPU stress process was stopped and the environment was left untouched.

Desired capacity was not manually reduced.

The Target Tracking policy was allowed to complete the scale-in process automatically.

## Validation

Auto Scaling eventually reduced the additional capacity and returned the application toward its baseline configuration.

## Lessons Learned

Do not manually change:

```text
Desired Capacity
```

during an automatic scale-in test.

Doing so invalidates the evidence that Target Tracking performed the scale-in.

---

# Issue 4 – Target Became Unhealthy Behind the ALB

## Problem

During the controlled failure test, one application target changed to an unhealthy state.

## Root Cause

The Target Group Health Check could no longer receive the expected successful application response from that target.

The laboratory Health Check expected:

```text
Protocol: HTTP
Path: /
Port: Traffic Port
Success Code: 200
```

An EC2 instance can remain in the `running` state even when the web application is unavailable.

## Diagnosis

The following checks are useful:

```bash
sudo systemctl status httpd
```

```bash
curl -I http://localhost/
```

```bash
sudo ss -tulpn | grep ':80'
```

The Target Group health status and reason should also be reviewed in AWS.

## Resolution

The failure scenario was allowed to proceed so that the Auto Scaling recovery behavior could be validated.

The infrastructure detected the unhealthy application capacity and replaced the affected EC2 instance.

## Validation

A replacement EC2 instance was launched.

After initialization and successful Health Checks, the Target Group returned to a healthy state.

## Lessons Learned

This demonstrates an important distinction:

```text
EC2 running ≠ Application healthy
```

Application-level Health Checks are essential for detecting failures that basic instance state alone cannot identify.

---

# Issue 5 – Automatic Instance Replacement Takes Time

## Problem

After an unhealthy instance was detected, the replacement was not immediately available to receive traffic.

## Root Cause

Automatic recovery includes multiple stages:

```text
Failure Detection
      ↓
Health Status Change
      ↓
Auto Scaling Replacement
      ↓
New EC2 Launch
      ↓
User Data Execution
      ↓
Apache Startup
      ↓
Target Registration
      ↓
Health Check Success
```

Each stage requires time.

## Resolution

The Auto Scaling Activity History and Target Group health were monitored while the replacement instance initialized.

No unnecessary manual replacement was performed.

## Validation

The replacement instance eventually became healthy and the application returned to the expected capacity.

## Lessons Learned

Self-healing is automatic, but not instantaneous.

Recovery time must include provisioning, initialization, registration, and Health Check convergence.

---

# Issue 6 – CPU Stress Continued Longer Than Expected

## Problem

During Auto Scaling testing, CPU utilization can remain high if the stress process is still active.

## Diagnosis

Check for active `stress-ng` processes:

```bash
ps aux | grep stress-ng
```

CPU activity can also be reviewed using:

```bash
top
```

## Resolution

If the controlled test must be stopped manually:

```bash
sudo pkill stress-ng
```

Then verify:

```bash
ps aux | grep stress-ng
```

## Validation

CPU utilization should begin returning toward normal after the workload stops.

CloudWatch requires additional time to reflect the lower utilization.

## Lessons Learned

Always verify that the workload generator has actually stopped before troubleshooting delayed scale-in.

---

# Issue 7 – CloudWatch Still Shows High CPU After Stress Test Stops

## Problem

The stress workload ended, but the CloudWatch graph did not immediately show low CPU utilization.

## Root Cause

CloudWatch displays collected datapoints over time.

There can be a delay between:

```text
Local CPU decreases
        ↓
Metric collection
        ↓
CloudWatch datapoint
        ↓
Graph update
        ↓
Scaling evaluation
```

## Diagnosis

First confirm the local workload has stopped:

```bash
top
```

and:

```bash
ps aux | grep stress-ng
```

Then review the CloudWatch metric period and time range.

## Resolution

No infrastructure change is required if the local CPU is already normal.

Allow CloudWatch to receive the next datapoints.

## Lessons Learned

Monitoring systems represent sampled data, not an instantaneous terminal view.

---

# Issue 8 – Apache Application Does Not Respond

## Problem

An EC2 instance is running but the application does not return the expected web page.

## Diagnosis

Check Apache:

```bash
sudo systemctl status httpd
```

Check port 80:

```bash
sudo ss -tulpn | grep ':80'
```

Test locally:

```bash
curl -I http://localhost/
```

Review recent Apache service logs:

```bash
sudo journalctl -u httpd -n 100
```

## Possible Causes

- Apache is stopped.
- Apache failed during startup.
- User Data did not complete correctly.
- The application file was not generated.
- Port 80 is not listening.
- Security Group rules prevent remote access.
- Health Check configuration does not match the application.

## Resolution

If Apache is stopped:

```bash
sudo systemctl start httpd
```

If configuration was changed:

```bash
sudo systemctl restart httpd
```

## Validation

```bash
curl -I http://localhost/
```

should return a successful HTTP response.

---

# Issue 9 – New Auto Scaling Instance Does Not Become Healthy

## Problem

A new EC2 instance launches successfully but does not become a healthy Target Group member.

## Diagnosis

Review:

1. EC2 instance state.
2. EC2 system status checks.
3. User Data execution.
4. Apache status.
5. Port 80 listener.
6. Web Security Group.
7. Target Group Health Check.
8. Health Check path.
9. Expected HTTP success code.

Useful commands:

```bash
sudo systemctl status httpd
```

```bash
curl -I http://localhost/
```

```bash
sudo ss -tulpn | grep ':80'
```

## Possible Root Cause

The EC2 infrastructure can be healthy while the application initialization has failed.

This is why application-level Health Checks are required.

## Resolution

Correct the Launch Template/User Data or application configuration rather than manually configuring each Auto Scaling instance.

## Lessons Learned

In Auto Scaling environments, fixes should be applied to the source configuration used to create instances.

Manual changes to one instance are temporary and will be lost when that instance is replaced.

---

# Issue 10 – EFS Shared Storage Is Not Visible

## Problem

The expected shared filesystem or test file cannot be found from an EC2 instance.

## Diagnosis

Check mounted filesystems:

```bash
df -h
```

Check EFS mounts:

```bash
mount | grep efs
```

Inspect the mount directory:

```bash
ls -lah /mnt/efs
```

Also verify:

- EFS filesystem state.
- Mount Targets.
- Availability Zone/subnet configuration.
- EFS Security Group.
- NFS TCP port 2049.
- EC2-to-EFS connectivity.
- EFS utilities.

## Resolution

Correct the mount/network configuration and verify that NFS traffic is permitted between the authorized EC2 resources and EFS.

## Validation

Create a test file:

```bash
echo "NovaCommerce shared storage test" | sudo tee /mnt/efs/shared-test.txt
```

Read it:

```bash
cat /mnt/efs/shared-test.txt
```

The same file should be visible from another EC2 instance connected to the same filesystem.

## Lessons Learned

EFS troubleshooting requires checking both:

```text
Linux mount configuration
+
AWS network configuration
```

---

# Issue 11 – EFS Security Group Blocks NFS

## Problem

The EFS filesystem exists and Mount Targets are configured, but EC2 cannot establish NFS access.

## Root Cause

NFS requires:

```text
TCP 2049
```

If the EFS Security Group does not permit the authorized application source, the mount cannot communicate successfully.

## Resolution

Verify the EFS Security Group and permit TCP 2049 only from the required application resources/Security Group.

## Lessons Learned

Do not solve EFS connectivity problems by unnecessarily opening NFS to the entire Internet.

Use the narrowest valid source.

---

# Issue 12 – Application Cannot Connect to RDS

## Problem

The application tier cannot establish a MySQL connection to Amazon RDS.

## Diagnosis

Verify:

1. RDS status.
2. RDS endpoint.
3. Database port.
4. Database credentials.
5. RDS Security Group.
6. Source Security Group.
7. VPC/subnet connectivity.
8. Application configuration.

Expected database port:

```text
TCP 3306
```

## Security Check

The database should remain:

```text
Publicly accessible: No
```

unless there is a justified architecture requirement to expose it.

## Resolution

Correct the internal network or Security Group configuration.

Do not make the database public simply as a troubleshooting shortcut.

## Lessons Learned

Private database connectivity problems should be solved inside the application network path.

Security should not be weakened to make troubleshooting easier.

---

# Issue 13 – ALB Request Repeatedly Shows the Same EC2 Instance

## Problem

During load-balancing validation, repeated requests may appear to reach the same backend instance several times.

## Explanation

Load balancing does not guarantee a strict visible alternation such as:

```text
Instance A
Instance B
Instance A
Instance B
```

A small number of requests can legitimately reach the same healthy target repeatedly.

## Resolution

Send multiple requests and compare:

- Instance ID.
- Availability Zone.
- Private IP.

Example:

```bash
for i in {1..10}; do
  curl -s http://<ALB-DNS-NAME>
  echo
done
```

## Validation

The final laboratory evidence confirmed that requests were processed by different EC2 instances across multiple Availability Zones.

## Lessons Learned

Validate load balancing over multiple requests rather than expecting deterministic round-robin output from a few browser refreshes.

---

# Issue 14 – ALB Is Reachable but Returns an Error

## Problem

The Application Load Balancer DNS resolves, but the application is not successfully returned.

## Diagnosis

Check the infrastructure from front to back:

```text
ALB Listener
     ↓
Listener Rule
     ↓
Target Group
     ↓
Target Health
     ↓
Security Group
     ↓
EC2
     ↓
Apache
     ↓
Application
```

Review:

- Listener port.
- Listener forwarding rule.
- Target Group.
- Target health.
- Health Check path.
- Web Security Group.
- Apache service.
- Local HTTP response.

## Lessons Learned

Troubleshoot load-balanced applications layer by layer rather than changing multiple components simultaneously.

---

# Issue 15 – Private Route Table Has No Internet Gateway Route

## Observation

The private route table did not contain:

```text
0.0.0.0/0 → Internet Gateway
```

## Explanation

This was consistent with the intended network isolation.

A private subnet should not become public by adding a direct Internet Gateway route unless the architecture explicitly requires it.

## Lessons Learned

A missing Internet Gateway route is not automatically an error.

Routing must be evaluated according to the intended subnet role.

---

# Troubleshooting Methodology

A useful general method for this architecture is:

```text
1. Identify the failing layer
        ↓
2. Check current state
        ↓
3. Check monitoring/metrics
        ↓
4. Check network path
        ↓
5. Check Security Groups
        ↓
6. Check service/application
        ↓
7. Check AWS Activity History
        ↓
8. Change only one thing if required
        ↓
9. Validate again
```

---

# Quick Troubleshooting Matrix

| Symptom | First Checks |
|---|---|
| ALB unavailable | Listener, DNS, Security Group |
| Target unhealthy | Health Check, Apache, port 80 |
| No scale-out | CPU metric, policy, max capacity, Activity History |
| No scale-in | CPU recovery, stress process, stabilization |
| ASG graph has no data | ASG metrics collection, CloudWatch datapoints |
| New EC2 unhealthy | User Data, Apache, SG, Health Check |
| EFS unavailable | Mount Target, SG, TCP 2049, mount |
| RDS unavailable | Endpoint, SG, TCP 3306, credentials |
| Same backend appears repeatedly | Send more requests; compare Instance IDs/AZs |
| CPU remains high | Check `stress-ng` |
| Web page unavailable locally | `httpd`, port 80, logs |

---

# Essential Diagnostic Commands

## Apache

```bash
sudo systemctl status httpd
```

```bash
sudo journalctl -u httpd -n 100
```

```bash
curl -I http://localhost/
```

## Network

```bash
ip addr
```

```bash
ip route
```

```bash
sudo ss -tulpn
```

## CPU

```bash
top
```

```bash
ps aux | grep stress-ng
```

## EFS

```bash
df -h
```

```bash
mount | grep efs
```

```bash
ls -lah /mnt/efs
```

## ALB

```bash
curl -I http://<ALB-DNS-NAME>
```

---

# Final Lessons Learned

The main troubleshooting lessons from Lab 09 are:

- Do not assume AWS automation is instantaneous.
- Allow CloudWatch enough time to collect and evaluate datapoints.
- Do not manually alter desired capacity while validating automatic scaling.
- Distinguish EC2 health from application health.
- Use Target Group Health Checks to validate the application layer.
- Fix Launch Templates/User Data rather than manually repairing disposable Auto Scaling instances.
- Check Security Groups before weakening network isolation.
- Keep RDS private when public database access is not required.
- Validate EFS at both the AWS network layer and Linux filesystem layer.
- Use Activity History to understand Auto Scaling decisions.
- Validate load balancing with multiple requests.
- Troubleshoot one layer at a time.

---

# Related Files

```text
README.md
CHANGELOG.md
commands.md
interview-questions.md
resources.md
study-notes.md
troubleshooting.md
```

---

**Lab Status:** ✅ Completed
