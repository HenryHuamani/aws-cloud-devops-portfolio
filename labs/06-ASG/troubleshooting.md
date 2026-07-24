# Troubleshooting Guide

## Lab 06 – Amazon EC2 Auto Scaling

---

# Table of Contents

1. Launch Template Issues
2. Auto Scaling Group Issues
3. EC2 Instance Issues
4. User Data Issues
5. Application Load Balancer Issues
6. Target Group Issues
7. Health Check Issues
8. Apache Issues
9. IMDSv2 Issues
10. CloudWatch Issues
11. Common AWS Console Mistakes
12. Best Troubleshooting Practices

---

# 1. Launch Template Issues

## Problem

The Auto Scaling Group cannot launch new EC2 instances.

### Symptoms

- Activity History shows launch failures.
- Desired Capacity is never reached.

### Possible Causes

- Invalid AMI.
- Deleted Key Pair.
- Incorrect Security Group.
- Invalid IAM Role.
- Unsupported instance type.

### Solution

Verify:

- AMI exists.
- Instance type is available in the selected Region.
- Security Groups exist.
- Key Pair exists.
- Launch Template version is correct.

---

# 2. Auto Scaling Group Issues

## Problem

Desired Capacity is not maintained.

### Symptoms

Only one EC2 instance remains running when Desired Capacity is set to two.

### Possible Causes

- Launch failures.
- Maximum Capacity reached.
- Service quota exceeded.
- Invalid Launch Template.

### Solution

Review:

- Activity History.
- EC2 console.
- Launch Template.
- AWS Service Quotas.

---

# 3. EC2 Instance Issues

## Problem

Instance launches but immediately terminates.

### Symptoms

Instance state changes:

Pending

↓

Running

↓

Terminating

### Possible Causes

- Failed Health Checks.
- User Data errors.
- Application startup failure.

### Solution

Review:

- EC2 System Logs.
- Cloud-init logs.
- Target Group Health Checks.

---

# 4. User Data Issues

## Problem

Apache was not installed automatically.

### Symptoms

HTTP connection refused.

### Possible Causes

- Syntax errors.
- Missing permissions.
- Package installation failure.

### Solution

Review:

```bash
sudo cat /var/log/cloud-init-output.log
```

Correct the script and create a new Launch Template version.

---

## Problem

User Data executes but variables are empty.

### Possible Causes

IMDSv2 token not generated correctly.

### Solution

Verify:

```bash
TOKEN=$(curl -X PUT ...)
```

Ensure every metadata request includes the token.

---

# 5. Application Load Balancer Issues

## Problem

Website cannot be accessed.

### Symptoms

Browser displays:

- 502 Bad Gateway
- 503 Service Unavailable
- Timeout

### Possible Causes

- No healthy targets.
- Apache stopped.
- Listener misconfiguration.
- Security Group blocks HTTP.

### Solution

Verify:

- Listener configuration.
- Target Health.
- Apache service.
- Port 80.
- Security Groups.

---

# 6. Target Group Issues

## Problem

Targets remain Unhealthy.

### Possible Causes

- Wrong Health Check Path.
- Application not running.
- Port mismatch.
- HTTP response not 200.

### Solution

Test locally:

```bash
curl localhost
```

Ensure the application returns HTTP 200.

---

# 7. Health Check Issues

## Problem

Instances repeatedly fail Health Checks.

### Possible Causes

- Application startup is slow.
- Incorrect timeout.
- Wrong path.
- Firewall restrictions.

### Solution

Adjust:

- Health Check Interval.
- Timeout.
- Healthy Threshold.
- Unhealthy Threshold.
- Health Check Grace Period.

---

# 8. Apache Issues

## Problem

Apache service is inactive.

### Verify

```bash
systemctl status httpd
```

### Start Service

```bash
sudo systemctl start httpd
```

### Enable on Boot

```bash
sudo systemctl enable httpd
```

### Restart

```bash
sudo systemctl restart httpd
```

---

# 9. IMDSv2 Issues

## Problem

Metadata requests return:

```
401 Unauthorized
```

### Cause

Session token missing.

### Solution

Generate a token:

```bash
TOKEN=$(curl -X PUT \
"http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds:21600")
```

Then include:

```bash
-H "X-aws-ec2-metadata-token:$TOKEN"
```

---

# 10. CloudWatch Issues

## Problem

Auto Scaling never triggers.

### Possible Causes

- CloudWatch Alarm missing.
- Incorrect metric.
- Wrong threshold.

### Solution

Verify:

- Alarm state.
- Metric namespace.
- Evaluation periods.
- Threshold values.

---

# 11. Common AWS Console Mistakes

Some of the most common configuration errors include:

- Selecting the wrong Region.
- Choosing the wrong VPC.
- Incorrect subnet selection.
- Forgetting to attach the Target Group.
- Using an outdated Launch Template version.
- Incorrect Security Group rules.
- Forgetting to enable IMDSv2.
- Invalid Health Check Path.

---

# 12. Best Troubleshooting Practices

When troubleshooting Auto Scaling environments:

1. Do not guess.
2. Reproduce the problem.
3. Review CloudWatch Metrics.
4. Review Auto Scaling Activity History.
5. Verify Health Checks.
6. Review User Data logs.
7. Validate networking.
8. Test locally before modifying infrastructure.
9. Change one parameter at a time.
10. Document every incident and its resolution.

Following a structured troubleshooting process reduces recovery time and improves operational reliability.

---

# Summary

Most Auto Scaling issues originate from configuration errors rather than service failures.

A systematic troubleshooting approach—starting with Activity History, Health Checks, logs and networking—allows problems to be identified and resolved efficiently while maintaining application availability.