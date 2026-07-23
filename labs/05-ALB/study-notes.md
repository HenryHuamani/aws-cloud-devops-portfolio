# Study Notes

## Laboratory

**Lab 05 – Application Load Balancer**

This document summarizes the main concepts learned during the implementation of an AWS Application Load Balancer architecture.

---

## What Is an Application Load Balancer?

An Application Load Balancer, or ALB, is a Layer 7 load balancer provided by AWS Elastic Load Balancing.

It receives incoming HTTP or HTTPS requests and distributes them across multiple registered targets, such as:

- Amazon EC2 instances
- Containers
- IP addresses
- AWS Lambda functions

The ALB analyzes application-level information, including:

- Host headers
- URL paths
- HTTP methods
- Query strings
- Source IP addresses
- HTTP headers

---

## OSI Layer

The Application Load Balancer operates at:

```text
Layer 7 – Application Layer
```

Because it works at Layer 7, it can make routing decisions based on HTTP and HTTPS request information.

This distinguishes it from a Network Load Balancer, which operates at Layer 4.

---

## Main Architecture

```text
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
Listener
   │
   ▼
Target Group
   │
   ├───────────────┐
   ▼               ▼
EC2 Server 01   EC2 Server 02
```

The main traffic flow is:

1. The client sends a request to the ALB DNS name.
2. The ALB listener receives the request.
3. The listener evaluates its forwarding rules.
4. The request is forwarded to a Target Group.
5. The ALB selects a healthy target.
6. The target processes the request and returns a response.

---

## Application Load Balancer

The Application Load Balancer is the public entry point of the architecture.

Resource used in this laboratory:

```text
portfolio-alb
```

Main configuration:

```text
Scheme: Internet-facing
IP address type: IPv4
Listener: HTTP
Listener port: 80
VPC: portfolio-vpc
```

An internet-facing ALB has public IP addresses managed by AWS and can receive traffic from the internet.

Users should access the application through the ALB DNS name rather than through the public IP address of an individual EC2 instance.

---

## ALB DNS Name

AWS automatically assigns a DNS name to every Application Load Balancer.

Example:

```text
portfolio-alb-xxxxxxxx.us-east-2.elb.amazonaws.com
```

The DNS name should be used because the underlying IP addresses of the ALB are managed by AWS and can change.

The laboratory was tested using:

```text
http://<alb-dns-name>
```

HTTPS was not used because the ALB only had an HTTP listener on port 80.

---

## Listener

A listener checks for connection requests using a configured protocol and port.

Laboratory configuration:

```text
Protocol: HTTP
Port: 80
Default action: Forward to portfolio-web-tg
```

A listener contains:

- Protocol
- Port
- Default action
- Optional routing rules

When the ALB receives a request on port 80, the listener forwards it to the associated Target Group.

---

## Listener Rules

Listener rules determine how requests are routed.

Each rule contains:

- A priority
- One or more conditions
- One or more actions

Common ALB rule conditions include:

- Host header
- Path pattern
- HTTP header
- HTTP request method
- Query string
- Source IP

Example of path-based routing:

```text
/app1/* → Target Group A
/app2/* → Target Group B
```

Example of host-based routing:

```text
api.example.com → API Target Group
web.example.com → Web Target Group
```

This laboratory used only the default forwarding rule.

---

## Target Group

A Target Group is a logical group of backend resources that receive traffic from the load balancer.

Resource used:

```text
portfolio-web-tg
```

Configuration:

```text
Target type: Instances
Protocol: HTTP
Port: 80
Health check path: /
```

The Target Group contains the two EC2 web servers:

```text
portfolio-web-server-1
portfolio-web-server-2
```

The ALB does not forward traffic directly to arbitrary instances. It forwards requests to the Target Group, which manages the registered targets.

---

## Registered Targets

A registered target is a backend resource associated with a Target Group.

In this laboratory, the registered targets were EC2 instances.

A target may appear with statuses such as:

```text
Initial
Healthy
Unhealthy
Unused
Draining
Unavailable
```

### Healthy

The target successfully responds to the configured health check.

### Unhealthy

The target fails one or more health check requirements.

### Unused

The target is registered but is not currently receiving traffic.

This can happen when the Target Group is not yet associated with an active load balancer.

### Draining

The target is being deregistered and existing connections are being completed before traffic is fully stopped.

---

## Health Checks

Health checks allow the ALB to determine whether a registered target can receive traffic.

Laboratory configuration:

```text
Protocol: HTTP
Port: Traffic port
Path: /
```

The ALB periodically sends a request to the health check path.

If the target returns an acceptable HTTP response code, it is considered healthy.

Only healthy targets receive new requests.

---

## Health Check Parameters

Important health check settings include:

| Parameter | Purpose |
|---|---|
| Protocol | Protocol used for the health check |
| Port | Port checked by the Target Group |
| Path | Application endpoint used for validation |
| Healthy threshold | Successful checks required to become healthy |
| Unhealthy threshold | Failed checks required to become unhealthy |
| Timeout | Maximum time to wait for a response |
| Interval | Time between health checks |
| Success codes | HTTP codes considered successful |

A common health check path is:

```text
/
```

In a real application, a dedicated endpoint is preferable:

```text
/health
```

or:

```text
/healthcheck
```

---

## Multi-AZ Deployment

The ALB was deployed across two Availability Zones:

```text
us-east-2a
us-east-2b
```

Subnets:

```text
Public Subnet A: 10.0.1.0/24
Public Subnet B: 10.0.3.0/24
```

Each Availability Zone contained one EC2 instance.

This architecture improves availability because traffic can continue to be routed to the healthy server if another target becomes unavailable.

---

## Minimum Subnet Requirement

An Application Load Balancer requires at least two subnets in different Availability Zones.

This allows AWS to create load balancer nodes across multiple zones.

For an internet-facing ALB, the selected subnets should normally be public and have routes to an Internet Gateway.

---

## Public Subnet

A subnet is considered public when its associated route table contains a route to an Internet Gateway.

Example:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

Both ALB subnets were associated with the public route table.

---

## Security Groups

Security Groups act as virtual firewalls for AWS resources.

In this laboratory, HTTP traffic was allowed on port 80.

A basic laboratory configuration may allow:

```text
HTTP 80 from 0.0.0.0/0
SSH 22 from a trusted public IP
```

For production, the recommended design is:

```text
Internet
   │
   ▼
ALB Security Group
Allows HTTP/HTTPS from users
   │
   ▼
EC2 Security Group
Allows HTTP only from ALB Security Group
```

The EC2 instances should not accept application traffic directly from the entire internet.

---

## Why Separate Security Groups?

Using separate Security Groups provides better isolation.

### ALB Security Group

Allows:

```text
HTTP 80 from 0.0.0.0/0
HTTPS 443 from 0.0.0.0/0
```

### EC2 Security Group

Allows:

```text
HTTP 80 from ALB Security Group
SSH 22 from trusted administrator IP
```

This ensures that users reach the application through the load balancer rather than bypassing it.

---

## HTTP Versus HTTPS

The laboratory used HTTP on port 80.

```text
http://<alb-dns-name>
```

An HTTPS request would fail because no HTTPS listener was configured.

For HTTPS, the ALB requires:

- Listener on port 443
- SSL/TLS certificate
- AWS Certificate Manager
- HTTPS forwarding configuration

A production design should redirect HTTP traffic to HTTPS.

---

## Load Distribution

The ALB distributes incoming requests among healthy targets.

In the laboratory, each EC2 instance displayed a different server name:

```text
Server 01
Server 02
```

By refreshing the ALB DNS page multiple times, responses from both servers could be observed.

This confirmed that requests were being distributed between registered targets.

---

## Stateless Applications

Applications behind a load balancer should preferably be stateless.

A stateless application does not depend on local session data stored on one specific EC2 instance.

State should instead be stored in shared services such as:

- Amazon RDS
- Amazon DynamoDB
- Amazon ElastiCache
- Amazon S3

This allows any healthy backend instance to process a request.

---

## Sticky Sessions

Sticky sessions bind a user session to a specific target.

They can be implemented using ALB-generated cookies or application-based cookies.

Sticky sessions may be useful when an application stores session state locally, but they can reduce even load distribution.

The preferred architecture is usually to design the application as stateless.

Sticky sessions were not configured in this laboratory.

---

## Cross-Zone Load Balancing

Cross-zone load balancing allows a load balancer node in one Availability Zone to distribute traffic across targets in other enabled Availability Zones.

For Application Load Balancers, cross-zone load balancing is enabled by default at the load balancer level.

This improves traffic distribution when the number of targets differs between zones.

---

## Deregistration Delay

When a target is removed from a Target Group, the ALB can allow existing requests to complete.

This period is called the deregistration delay.

During this time, the target appears as:

```text
Draining
```

This helps prevent active user requests from being interrupted during deployments or scaling operations.

---

## Routing Algorithms

Application Load Balancers can use routing behavior such as:

- Round robin
- Least outstanding requests
- Weighted random

The exact algorithm depends on the Target Group configuration and AWS-supported attributes.

For a basic laboratory, the default behavior is sufficient.

---

## ALB Versus Direct EC2 Access

Direct EC2 access:

```text
Client → EC2 public IP
```

Disadvantages:

- Single point of failure
- No automatic health-based routing
- No centralized TLS termination
- No advanced routing
- Difficult horizontal scaling

ALB access:

```text
Client → ALB → Healthy EC2 targets
```

Advantages:

- High availability
- Health checks
- Multiple backend instances
- Path-based routing
- Host-based routing
- TLS termination
- Integration with Auto Scaling

---

## ALB Versus Network Load Balancer

| Feature | ALB | NLB |
|---|---|---|
| OSI layer | Layer 7 | Layer 4 |
| Main protocols | HTTP, HTTPS | TCP, UDP, TLS |
| Path-based routing | Yes | No |
| Host-based routing | Yes | No |
| Static IP support | No direct static IP | Yes |
| Performance | Application traffic | Very high network performance |
| Typical use | Websites, APIs, microservices | Gaming, TCP services, extreme throughput |

---

## ALB Versus Gateway Load Balancer

A Gateway Load Balancer is designed for deploying and scaling virtual network appliances.

Examples:

- Firewalls
- Intrusion detection systems
- Intrusion prevention systems
- Deep packet inspection appliances

It is not a replacement for an ALB in a standard web application architecture.

---

## Integration With Auto Scaling

An ALB can be integrated with an Auto Scaling Group.

```text
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
Target Group
   │
   ▼
Auto Scaling Group
   │
   ├── EC2
   ├── EC2
   └── EC2
```

The Auto Scaling Group automatically:

- Launches instances
- Terminates instances
- Registers new instances
- Deregisters terminated instances
- Maintains the desired capacity

This will be implemented in Lab 06.

---

## Monitoring

Application Load Balancers publish metrics to Amazon CloudWatch.

Important metrics include:

```text
RequestCount
TargetResponseTime
HTTPCode_ELB_4XX_Count
HTTPCode_ELB_5XX_Count
HTTPCode_Target_4XX_Count
HTTPCode_Target_5XX_Count
HealthyHostCount
UnHealthyHostCount
ActiveConnectionCount
RejectedConnectionCount
```

These metrics can be used to create CloudWatch dashboards and alarms.

---

## Access Logs

ALB access logs can be stored in Amazon S3.

They record information such as:

- Request time
- Client IP address
- Target IP address
- Request path
- Response code
- Processing time
- User agent

Access logs are useful for:

- Troubleshooting
- Security analysis
- Traffic analysis
- Auditing

They were not enabled in this basic laboratory.

---

## Common Causes of Unhealthy Targets

A target may become unhealthy because:

- Apache is not running.
- Port 80 is not listening.
- The Security Group blocks traffic.
- The health check path does not exist.
- The application returns an invalid status code.
- The subnet route is incorrect.
- The Network ACL blocks traffic.
- User Data did not finish successfully.
- The instance is registered on the wrong port.

---

## Common Causes of ALB Timeouts

Common causes include:

- No healthy targets.
- Incorrect listener configuration.
- Security Group restrictions.
- Apache service stopped.
- Incorrect Target Group port.
- Incorrect health check path.
- Application response timeout.
- Attempting to access HTTPS without an HTTPS listener.

In this laboratory, one apparent connectivity issue occurred because the EC2 server was accessed using HTTPS instead of HTTP.

---

## AWS Best Practices

- Deploy the ALB across at least two Availability Zones.
- Use separate Security Groups for the ALB and backend instances.
- Allow backend HTTP access only from the ALB Security Group.
- Use HTTPS for production traffic.
- Store certificates in AWS Certificate Manager.
- Redirect HTTP to HTTPS.
- Deploy backend instances in private subnets.
- Use an Auto Scaling Group.
- Configure health checks using a dedicated endpoint.
- Enable CloudWatch monitoring.
- Enable ALB access logs.
- Avoid storing application state on individual EC2 instances.
- Use Route 53 for a custom domain.
- Automate infrastructure using Terraform or CloudFormation.

---

## Key Learning Outcomes

After completing this laboratory, the following concepts were understood:

- How an Application Load Balancer works.
- How to create and configure a Target Group.
- How to register EC2 instances as targets.
- How listeners forward requests.
- How health checks determine target availability.
- How to deploy resources across multiple Availability Zones.
- How the ALB DNS name is used.
- Why HTTP and HTTPS listeners behave differently.
- How Security Groups control ALB and EC2 communication.
- How ALB prepares the architecture for Auto Scaling.