# Troubleshooting Guide

## Laboratory

**Lab 05 – Application Load Balancer**

This document records the main issues encountered during the implementation of the Application Load Balancer architecture, together with their causes, diagnostic steps and solutions.

---

## Troubleshooting Methodology

When an Application Load Balancer does not respond correctly, the problem should be analyzed in the following order:

```text
Client
  │
  ▼
ALB DNS
  │
  ▼
Listener
  │
  ▼
Target Group
  │
  ▼
Health Checks
  │
  ▼
Security Groups
  │
  ▼
EC2 Instance
  │
  ▼
Apache Web Server
```

This approach helps isolate the failure without changing multiple components at the same time.

---

## Issue 01 – EC2 Website Did Not Open

### Symptom

The second EC2 instance appeared to be unavailable from the browser.

The page did not load even though the instance was running.

### Initial Assumption

The issue was initially suspected to be related to:

- Apache installation
- User Data execution
- Security Group configuration
- Route table configuration
- Network ACL rules
- EC2 instance health

### Root Cause

The browser was attempting to access the server using HTTPS:

```text
https://<ec2-public-ip>
```

However, Apache was only configured to listen on HTTP port 80.

The correct address was:

```text
http://<ec2-public-ip>
```

### Solution

Access the web server using HTTP:

```text
http://<ec2-public-ip>
```

### Validation

The page loaded correctly after replacing `https://` with `http://`.

### Lesson Learned

Always verify that the requested protocol matches the configured listener or web server port.

```text
HTTP  → Port 80
HTTPS → Port 443
```

---

## Issue 02 – ALB DNS Did Not Respond

### Symptom

The Application Load Balancer DNS name did not initially display the web application.

### Possible Causes

The issue could have been caused by:

- ALB still provisioning
- No listener configured
- Incorrect default action
- No healthy targets
- Security Group blocking port 80
- Incorrect Target Group port
- Apache not running
- HTTPS used without an HTTPS listener

### Diagnostic Steps

#### 1. Verify ALB state

In the AWS console, confirm:

```text
State: Active
```

An ALB may take several minutes to become active after creation.

#### 2. Verify listener

Confirm the listener exists:

```text
Protocol: HTTP
Port: 80
Default action: Forward to portfolio-web-tg
```

#### 3. Verify Target Group health

Confirm that the registered targets show:

```text
Healthy
```

#### 4. Verify the access URL

Use:

```text
http://<alb-dns-name>
```

Do not use HTTPS unless a port 443 listener and certificate are configured.

### Solution

After confirming that the ALB was active, the listener was configured and the targets were healthy, the application was accessed through the ALB DNS name using HTTP.

### Validation

The ALB returned responses from both backend EC2 instances.

---

## Issue 03 – Targets Displayed as Unused

### Symptom

The EC2 instances were registered in the Target Group, but their status appeared as:

```text
Unused
```

### Root Cause

The Target Group had not yet been associated with an active Application Load Balancer listener.

A registered target may appear as unused when:

- The Target Group is not attached to a load balancer.
- The Availability Zone is not enabled.
- The target is registered but cannot receive traffic through any listener rule.

### Solution

Create the Application Load Balancer and configure its listener to forward traffic to:

```text
portfolio-web-tg
```

### Validation

After the association, the targets entered the health-check process and later appeared as:

```text
Healthy
```

### Lesson Learned

Registering instances in a Target Group is not enough. The Target Group must also be associated with a listener rule.

---

## Issue 04 – Target Group Showed Unhealthy Targets

### Symptom

One or more EC2 instances appeared as:

```text
Unhealthy
```

### Possible Causes

- Apache was not running.
- Port 80 was not listening.
- The health check path did not exist.
- The instance Security Group blocked ALB traffic.
- The Target Group used the wrong port.
- User Data had not completed.
- The application returned an invalid HTTP status code.
- The Network ACL blocked traffic.

### Diagnostic Commands

Check Apache:

```bash
sudo systemctl status httpd
```

Check port 80:

```bash
sudo ss -tulnp | grep :80
```

Test locally:

```bash
curl -I http://localhost
```

Check the page:

```bash
curl http://localhost
```

Review Apache logs:

```bash
sudo journalctl -u httpd
```

Review User Data execution:

```bash
sudo journalctl -u cloud-init
```

Inspect cloud-init output:

```bash
sudo tail -n 100 /var/log/cloud-init-output.log
```

### Correct Configuration

```text
Target Group protocol: HTTP
Target Group port: 80
Health check protocol: HTTP
Health check path: /
```

### Expected Result

```text
HTTP/1.1 200 OK
```

### Solution

Verify that Apache is active, the page exists, port 80 is listening and the Security Group allows communication from the ALB.

---

## Issue 05 – Apache Was Not Running

### Symptom

The EC2 instance was running, but the website did not respond.

### Diagnosis

```bash
sudo systemctl status httpd
```

Possible output:

```text
inactive
failed
```

### Solution

Start Apache:

```bash
sudo systemctl start httpd
```

Enable it at boot:

```bash
sudo systemctl enable httpd
```

Restart it:

```bash
sudo systemctl restart httpd
```

### Validation

```bash
sudo systemctl is-active httpd
```

Expected output:

```text
active
```

---

## Issue 06 – Apache Was Not Listening on Port 80

### Symptom

Apache appeared installed, but the browser and ALB health checks failed.

### Diagnosis

```bash
sudo ss -tulnp | grep :80
```

If no result is returned, no service is listening on port 80.

### Solution

Restart Apache:

```bash
sudo systemctl restart httpd
```

Then verify again:

```bash
sudo ss -tulnp | grep :80
```

Expected result:

```text
LISTEN ... :80
```

---

## Issue 07 – User Data Did Not Configure the Instance

### Symptom

The EC2 instance started, but Apache or the custom web page was missing.

### Possible Causes

- Syntax error in the script
- Invalid package command
- Incorrect heredoc syntax
- User Data executed only during the first launch
- Script terminated before completion
- Package repositories temporarily unavailable

### Diagnostic Commands

```bash
sudo journalctl -u cloud-init
```

```bash
sudo cat /var/log/cloud-init-output.log
```

```bash
sudo tail -n 100 /var/log/cloud-init.log
```

Verify Apache installation:

```bash
rpm -q httpd
```

Verify the web page:

```bash
ls -la /var/www/html
```

```bash
cat /var/www/html/index.html
```

### Important Note

EC2 User Data normally runs only during the first boot.

Editing the User Data after the instance has already launched does not automatically execute it again.

### Manual Re-execution

For testing purposes, the script can be copied and run manually:

```bash
sudo bash scripts/user-data.sh
```

### Solution

Correct the script and either:

- Launch a new instance.
- Run the script manually.
- Reconfigure cloud-init to execute again.

For a clean laboratory, launching a new instance is usually the simplest option.

---

## Issue 08 – Security Group Blocked HTTP Traffic

### Symptom

Apache worked locally, but the instance or ALB could not reach it.

### Local Test

```bash
curl http://localhost
```

If this works but remote access fails, the problem may be related to network security.

### Laboratory Configuration

For a basic laboratory:

```text
HTTP
Port: 80
Source: 0.0.0.0/0
```

### Recommended Production Configuration

ALB Security Group:

```text
HTTP 80 from 0.0.0.0/0
HTTPS 443 from 0.0.0.0/0
```

EC2 Security Group:

```text
HTTP 80 from ALB Security Group
SSH 22 from trusted administrator IP
```

### Solution

Allow the required traffic while avoiding unnecessarily open rules.

---

## Issue 09 – Incorrect Route Table Association

### Symptom

The internet-facing ALB or EC2 instances did not have expected internet connectivity.

### Verification

Both public subnets should be associated with a route table containing:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

### Possible Problem

The second subnet may have been created without being associated with the public route table.

### Solution

Associate both public subnets with the public route table.

Example:

```text
Public Subnet A → Public Route Table
Public Subnet B → Public Route Table
```

### Lesson Learned

A subnet does not become public only because it has a public name. Its route table must include a route to an Internet Gateway.

---

## Issue 10 – Network ACL Suspected of Blocking Traffic

### Symptom

The Security Groups appeared correct, but connectivity was still being investigated.

### Verification

The default Network ACL was reviewed.

It allowed inbound and outbound traffic.

### Important Difference

Security Groups are stateful.

Network ACLs are stateless.

If a custom Network ACL is used, both request and response traffic must be explicitly allowed.

### Common Requirements

Inbound:

```text
HTTP 80
Ephemeral ports when required
```

Outbound:

```text
Ephemeral ports
HTTP/HTTPS as required
```

### Result

The Network ACL was not the cause of the issue in this laboratory.

---

## Issue 11 – Wrong Health Check Path

### Symptom

Apache was running, but the target remained unhealthy.

### Possible Cause

The configured health check path did not exist.

For example:

```text
/health
```

would fail if the server only had:

```text
/
```

### Diagnosis

Test the configured path:

```bash
curl -I http://localhost/
```

or:

```bash
curl -I http://localhost/health
```

### Solution

Use a path that returns a successful HTTP code.

Laboratory path:

```text
/
```

Recommended production path:

```text
/health
```

---

## Issue 12 – Wrong Target Group Port

### Symptom

The targets remained unhealthy even though Apache was working on port 80.

### Possible Cause

The Target Group was configured with a different port.

Example of incorrect configuration:

```text
Target Group port: 8080
Apache port: 80
```

### Solution

Ensure both values match:

```text
Target Group port: 80
Apache listener: 80
```

---

## Issue 13 – HTTPS Access Failed

### Symptom

The ALB or EC2 page did not open using:

```text
https://...
```

### Root Cause

No HTTPS listener existed.

The environment only had:

```text
HTTP listener
Port 80
```

### Solution for the Laboratory

Use:

```text
http://<alb-dns-name>
```

### Production Solution

Configure:

```text
HTTPS listener: 443
Certificate: AWS Certificate Manager
Default action: Forward to Target Group
```

Optionally configure HTTP redirection:

```text
HTTP 80 → Redirect to HTTPS 443
```

---

## Issue 14 – ALB DNS Name Used Incorrectly

### Symptom

The user was unsure which value from the ALB console should be opened.

### Correct Value

Use the DNS name shown in the ALB details page.

Example:

```text
portfolio-alb-xxxxxxxx.us-east-2.elb.amazonaws.com
```

### Correct Format

```text
http://portfolio-alb-xxxxxxxx.us-east-2.elb.amazonaws.com
```

### Incorrect Approaches

Do not use:

- The ARN
- The Target Group ARN
- The ALB resource ID
- A private EC2 hostname
- HTTPS without a 443 listener

---

## Issue 15 – Only One Server Appeared Repeatedly

### Symptom

Refreshing the ALB DNS page repeatedly appeared to return the same server.

### Possible Causes

- Browser cache
- Sticky sessions
- Only one healthy target
- One target still initializing
- Uneven request distribution during a small test
- Persistent TCP connections

### Diagnostic Steps

Confirm both targets are healthy.

Use repeated command-line requests:

```bash
for i in {1..10}; do
  curl -s http://<alb-dns-name> | grep "Server"
done
```

Use a new connection for each request:

```bash
for i in {1..10}; do
  curl -s -H "Connection: close" http://<alb-dns-name> | grep "Server"
done
```

### Solution

Confirm both targets are healthy and perform multiple independent requests.

### Lesson Learned

A small number of browser refreshes does not always demonstrate perfectly alternating responses.

Load balancing does not necessarily mean strict server-by-server alternation.

---

## Issue 16 – Server Name Did Not Match the Instance

### Symptom

The web page displayed an incorrect server number or Availability Zone.

### Root Cause

The reusable User Data script contained manually defined variables:

```bash
SERVER_NAME="Server 01"
AVAILABILITY_ZONE="us-east-2a"
```

If these values were not changed before launching the second instance, the page could display incorrect information.

### Solution

For Server 02, update:

```bash
SERVER_NAME="Server 02"
AVAILABILITY_ZONE="us-east-2b"
```

### Future Improvement

Use EC2 Instance Metadata Service v2 to detect the Availability Zone automatically.

This improvement will be implemented in the Auto Scaling laboratory.

---

## Diagnostic Checklist

When the ALB does not work, verify the following:

```text
[ ] ALB state is Active
[ ] Correct ALB DNS name is used
[ ] URL uses HTTP, not HTTPS
[ ] Listener exists on port 80
[ ] Listener forwards to the correct Target Group
[ ] Both Availability Zones are enabled
[ ] Targets are registered
[ ] Targets are Healthy
[ ] Health check path is correct
[ ] Target Group port is 80
[ ] Apache is active
[ ] Apache listens on port 80
[ ] index.html exists
[ ] ALB Security Group allows HTTP
[ ] EC2 Security Group allows ALB traffic
[ ] Public subnets use the public route table
[ ] Public route table points to the Internet Gateway
[ ] Network ACL permits required traffic
```

---

## Useful Linux Commands

### Apache status

```bash
sudo systemctl status httpd
```

### Restart Apache

```bash
sudo systemctl restart httpd
```

### Confirm Apache starts at boot

```bash
sudo systemctl is-enabled httpd
```

### Verify port 80

```bash
sudo ss -tulnp | grep :80
```

### Test local HTTP response

```bash
curl -I http://localhost
```

### Display the website

```bash
curl http://localhost
```

### Review Apache logs

```bash
sudo journalctl -u httpd --no-pager
```

### Review cloud-init logs

```bash
sudo journalctl -u cloud-init --no-pager
```

### Review User Data output

```bash
sudo tail -n 100 /var/log/cloud-init-output.log
```

### Verify the web page file

```bash
sudo ls -la /var/www/html
```

### Verify hostname and IP

```bash
hostname
hostname -I
```

---

## Lessons Learned

- A protocol mismatch can look like a network or server failure.
- HTTP and HTTPS must not be treated as interchangeable.
- Registered targets can remain unused until the Target Group is associated with a listener.
- Only healthy targets receive ALB traffic.
- Local testing with `curl` helps separate application problems from AWS networking problems.
- User Data logs are essential when automated configuration fails.
- A public subnet requires an Internet Gateway route.
- Security Groups and Network ACLs should be checked separately.
- The ALB DNS name should be used instead of individual EC2 public IP addresses.
- Load distribution should be validated with multiple independent requests.