# Amazon EC2 - Study Notes

---

# What is Amazon EC2?

Amazon Elastic Compute Cloud (EC2) is AWS's Infrastructure as a Service (IaaS) offering that provides secure, scalable, and resizable virtual servers in the cloud.

EC2 allows users to deploy applications without managing physical hardware while maintaining full control over the operating system.

EC2 is one of the core AWS compute services and is widely used to host web applications, APIs, databases, CI/CD runners, development environments, and enterprise workloads.

---

# Key Characteristics

- Elastic and scalable compute capacity.
- Multiple operating systems supported.
- Pay-as-you-go pricing.
- Wide variety of instance types.
- Integration with most AWS services.
- Full operating system access.

---

# Core Components

## EC2 Instance

A virtual machine running inside AWS.

Each instance contains:

- Operating System
- CPU
- Memory
- Network Interface
- Storage
- Security Configuration

---

## Amazon Machine Image (AMI)

An AMI is a template used to launch EC2 instances.

It contains:

- Operating System
- Installed Software
- Configuration
- Storage Mapping

Common AMIs

- Ubuntu Server
- Amazon Linux
- Red Hat Enterprise Linux
- Windows Server

---

## Instance Types

Instance Types define the hardware resources assigned to an EC2 instance.

Examples

| Family | Purpose |
|----------|---------|
| t | General Purpose (Burstable) |
| m | General Purpose |
| c | Compute Optimized |
| r | Memory Optimized |
| x | High Memory |
| p | GPU |
| g | Graphics |

Example used in this laboratory

```
t2.micro
```

Specifications

- 1 vCPU
- 1 GiB RAM
- AWS Free Tier eligible

---

## Amazon EBS

Elastic Block Store (EBS) provides persistent block storage for EC2.

Characteristics

- Persistent storage
- Can be detached
- Can be snapshotted
- High durability

In this laboratory

```
8 GB gp3
```

---

## Public IPv4

Allows Internet connectivity.

Without a Public IP, the instance cannot be accessed directly from the Internet.

---

## Security Groups

Security Groups act as virtual firewalls.

They control:

- Inbound traffic
- Outbound traffic

This laboratory

Inbound

```
SSH
Port 22
Source: My IP
```

---

## Key Pair

A Key Pair is used for secure SSH authentication.

Components

Public Key

Stored inside AWS.

Private Key (.pem)

Downloaded once and stored securely by the administrator.

---

# EC2 Instance Lifecycle

```
Pending

↓

Running

↓

Stopping

↓

Stopped

↓

Starting

↓

Running

↓

Terminated
```

Notes

- Running → billed.
- Stopped → compute billing stops.
- Terminated → cannot be recovered.

---

# SSH Authentication Flow

```
Windows PowerShell

↓

SSH Client

↓

Private Key (.pem)

↓

Security Group

↓

Ubuntu Server

↓

Linux Shell
```

---

# Pricing Models

## On-Demand

Pay only while the instance is running.

Best for:

- Learning
- Development
- Testing

---

## Reserved Instances

Commitment of 1 or 3 years.

Lower cost.

Best for:

- Predictable workloads

---

## Spot Instances

Use unused AWS capacity.

Very low cost.

Can be interrupted by AWS.

Best for:

- Batch processing
- Big Data
- CI/CD

---

## Savings Plans

Flexible pricing model based on usage commitment.

---

# EC2 Best Practices

✔ Use the smallest instance required.

✔ Restrict SSH access.

✔ Protect Key Pairs.

✔ Stop unused instances.

✔ Use IAM Roles instead of Access Keys.

✔ Enable monitoring.

✔ Use Security Groups instead of opening unnecessary ports.

✔ Keep the operating system updated.

---

# Common Ports

| Port | Service |
|------|---------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 3389 | RDP |

---

# Free Tier

Current laboratory

Instance

```
t2.micro
```

Storage

```
8 GB gp3
```

Estimated monthly cost

```
USD 0
```

(Within AWS Free Tier limits.)

---

# Lab Summary

Resources created

- EC2 Instance
- Security Group
- Key Pair
- EBS Volume

Successfully completed

- Launch Instance
- Configure SSH
- Connect from Windows
- Resolve SSH authentication
- Access Linux terminal

---

# Key Concepts

| Concept | Description |
|----------|-------------|
| EC2 | Virtual machine |
| AMI | Operating System template |
| EBS | Persistent storage |
| Key Pair | SSH authentication |
| Security Group | Virtual firewall |
| Public IP | Internet connectivity |
| SSH | Secure remote access |
| Instance Type | CPU and Memory configuration |

---

# Interview Tip

A common interview question is:

**What is the difference between Security Groups and Network ACLs?**

Expected answer

Security Groups

- Instance level.
- Stateful.
- Allow rules only.

Network ACLs

- Subnet level.
- Stateless.
- Allow and Deny rules.

(Network ACLs will be covered in the VPC laboratory.)

---

# References

https://docs.aws.amazon.com/ec2/

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/

https://aws.amazon.com/ec2/
