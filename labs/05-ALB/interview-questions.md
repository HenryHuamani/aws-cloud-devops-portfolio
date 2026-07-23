# Interview Questions

## Laboratory

**Lab 05 – Application Load Balancer**

This document contains common interview questions related to AWS Application Load Balancers, along with concise answers based on the concepts implemented in this laboratory.

---

# Basic Questions

## 1. What is an Application Load Balancer?

An Application Load Balancer (ALB) is a Layer 7 load balancer provided by AWS Elastic Load Balancing.

It distributes HTTP and HTTPS traffic across multiple backend targets based on application-layer information such as host headers, URL paths, HTTP methods and query strings.

---

## 2. At which OSI layer does an ALB operate?

An ALB operates at:

```text
Layer 7 – Application Layer
```

Because it understands HTTP and HTTPS traffic, it can perform advanced routing decisions.

---

## 3. What protocols does an ALB support?

- HTTP
- HTTPS

Unlike a Network Load Balancer, an ALB is designed specifically for web applications.

---

## 4. What is a Listener?

A Listener checks for incoming client connections using a specific protocol and port.

Example:

```text
HTTP
Port 80
```

or

```text
HTTPS
Port 443
```

Each listener contains one or more forwarding rules.

---

## 5. What is a Target Group?

A Target Group is a logical collection of backend resources that receive traffic from the Application Load Balancer.

Targets may include:

- EC2 Instances
- IP Addresses
- ECS Tasks
- Lambda Functions

---

## 6. Why doesn't an ALB send traffic directly to EC2 instances?

Because the ALB always forwards requests through a Target Group.

The Target Group manages:

- Registered targets
- Health checks
- Routing decisions

---

## 7. What is a Health Check?

A Health Check is a periodic request sent by the ALB to determine whether a target is capable of serving traffic.

Only healthy targets receive requests.

---

## 8. What happens if a target becomes unhealthy?

The ALB stops routing new requests to that target.

Existing healthy targets continue serving traffic.

---

## 9. What happens if all targets become unhealthy?

The ALB cannot forward requests successfully.

Clients typically receive:

```text
503 Service Unavailable
```

---

## 10. Why should users access the ALB DNS instead of an EC2 Public IP?

Because:

- The ALB distributes traffic.
- AWS manages the ALB infrastructure.
- Backend instances can change.
- Auto Scaling may replace instances automatically.

---

# Intermediate Questions

## 11. What is the difference between an ALB and an NLB?

| ALB | NLB |
|-----|-----|
| Layer 7 | Layer 4 |
| HTTP / HTTPS | TCP / UDP / TLS |
| Host-based routing | No |
| Path-based routing | No |
| Web applications | High-performance networking |

---

## 12. What is Host-Based Routing?

The ALB routes traffic according to the HTTP Host header.

Example:

```text
api.example.com
```

↓

API Target Group

```text
web.example.com
```

↓

Website Target Group

---

## 13. What is Path-Based Routing?

The ALB routes traffic based on the requested URL path.

Example:

```text
/finance/*
```

↓

Finance Target Group

```text
/api/*
```

↓

API Target Group

---

## 14. What are Listener Rules?

Listener Rules define:

- Conditions
- Priorities
- Actions

The ALB evaluates these rules before forwarding requests.

---

## 15. Why is Multi-AZ important?

Deploying resources across multiple Availability Zones increases availability.

If one Availability Zone fails, traffic can continue flowing to healthy instances in another zone.

---

## 16. What is Cross-Zone Load Balancing?

Cross-Zone Load Balancing allows an ALB node in one Availability Zone to send traffic to healthy targets located in another enabled Availability Zone.

For Application Load Balancers, this feature is enabled by default.

---

## 17. What is Sticky Session?

Sticky Sessions bind a user to the same backend server using cookies.

Advantages:

- Maintains local session state

Disadvantages:

- Less even traffic distribution

Modern cloud applications generally prefer stateless architectures.

---

## 18. Why are stateless applications recommended?

Because any backend server can process any request.

State should be stored in shared services such as:

- Amazon RDS
- DynamoDB
- ElastiCache

This enables horizontal scaling.

---

## 19. Why should ALB and EC2 use different Security Groups?

This provides better isolation.

Recommended architecture:

```text
Internet

↓

ALB Security Group

↓

EC2 Security Group
```

The EC2 instances should only accept HTTP traffic from the ALB Security Group.

---

## 20. What metrics does CloudWatch provide for ALBs?

Examples include:

- RequestCount
- TargetResponseTime
- HealthyHostCount
- UnHealthyHostCount
- HTTPCode_ELB_5XX_Count
- HTTPCode_Target_5XX_Count

---

# Troubleshooting Questions

## 21. Why would a target appear as Unhealthy?

Possible causes include:

- Apache stopped
- Wrong port
- Invalid health check path
- Security Group restriction
- Application returning an error
- User Data failure

---

## 22. Why would a target appear as Unused?

Because it is registered but not associated with an active Load Balancer listener.

---

## 23. Why might an ALB DNS not respond?

Possible reasons:

- ALB still provisioning
- No listener
- No healthy targets
- Security Group restriction
- Wrong protocol (HTTPS instead of HTTP)

---

## 24. How would you verify Apache?

```bash
sudo systemctl status httpd
```

---

## 25. How would you verify that Apache listens on port 80?

```bash
sudo ss -tulnp | grep :80
```

---

## 26. How would you verify User Data execution?

```bash
sudo journalctl -u cloud-init
```

or

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

---

## 27. How do you verify that the application works locally?

```bash
curl http://localhost
```

---

# Scenario Questions

## 28. Your ALB returns 503. What would you check first?

A logical troubleshooting sequence would be:

1. ALB status
2. Listener configuration
3. Target Group
4. Health Checks
5. Security Groups
6. Apache status
7. Application response

---

## 29. One EC2 instance fails. What happens?

The ALB automatically routes traffic only to healthy targets.

If another healthy instance exists, the application remains available.

---

## 30. How would you make this architecture production-ready?

Recommended improvements include:

- HTTPS listener (443)
- AWS Certificate Manager
- Auto Scaling Group
- Private subnets for EC2
- Separate Security Groups
- CloudWatch alarms
- ALB Access Logs
- Route 53
- AWS WAF
- Infrastructure as Code (Terraform)

---

# Hands-On Questions

## 31. Which AWS services were used in this laboratory?

- Amazon EC2
- Amazon VPC
- Application Load Balancer
- Target Groups
- Security Groups
- Internet Gateway
- Route Tables

---

## 32. Which Availability Zones were used?

```text
us-east-2a
us-east-2b
```

---

## 33. What protocol was configured?

```text
HTTP
Port 80
```

---

## 34. Which Health Check path was used?

```text
/
```

---

## 35. Which Target Type was selected?

```text
Instances
```

---

## 36. Why did HTTPS initially fail during the laboratory?

Because only an HTTP listener on port 80 was configured.

There was no HTTPS listener or SSL/TLS certificate.

---

## 37. What was the most important lesson learned?

The most valuable lesson was understanding that a functioning load balancer depends on the correct interaction of multiple AWS components:

- VPC
- Subnets
- Route Tables
- Security Groups
- Target Groups
- Listeners
- Health Checks
- EC2 Instances
- Apache Web Server

A failure in any one of these components can prevent the application from being accessible.

---

# Final Interview Tips

When answering questions about an Application Load Balancer:

- Explain the complete request flow.
- Mention the role of Target Groups and Health Checks.
- Emphasize Multi-AZ deployment.
- Describe Security Group best practices.
- Compare ALB with NLB when appropriate.
- Use real troubleshooting examples from hands-on experience.
- Discuss production improvements such as Auto Scaling, HTTPS, WAF and Terraform.

Interviewers value practical experience and the ability to explain architectural decisions more than simply recalling definitions.