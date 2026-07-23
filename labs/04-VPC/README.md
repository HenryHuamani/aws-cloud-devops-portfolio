# Lab 04 - Amazon VPC

## Overview

This laboratory demonstrates how to build a secure and functional AWS network using Amazon Virtual Private Cloud (VPC). A custom VPC was created with public and private subnets, an Internet Gateway, custom Route Tables, Security Groups, and an EC2 instance hosting an Apache web server.

---

## Architecture

- Custom VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- Route Table
- Security Group
- Amazon EC2
- Apache HTTP Server

---

## AWS Services

- Amazon VPC
- Amazon EC2
- Internet Gateway
- Route Tables
- Security Groups
- Network ACL
- Cloud-Init

---

## Objectives

- Create a custom VPC.
- Configure public and private subnets.
- Attach an Internet Gateway.
- Configure routing.
- Deploy an EC2 instance.
- Install Apache automatically using User Data.
- Publish a web page.

---

## Architecture Diagram

The complete architecture diagram is available below.

![Amazon VPC Architecture](architecture/export/vpc.png)

---

## Evidence

See:

evidence/

---

## Skills Demonstrated

- AWS Networking
- VPC Design
- Public/Private Networking
- Security Groups
- Route Tables
- Internet Gateway
- EC2 Deployment
- Linux Administration
- Cloud-init Automation

---

## Result

The EC2 instance was successfully deployed inside a custom VPC and served a web application through its public IPv4 address.
