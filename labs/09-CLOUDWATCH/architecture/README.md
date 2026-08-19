# Architecture – Lab 09 CloudWatch

## Purpose

This directory documents the architecture monitored and validated during Lab 09.

Lab 09 does **not** recreate the entire NovaCommerce platform from scratch. It reuses the existing VPC, ALB, EC2 Auto Scaling, EFS, and RDS resources from previous labs and adds a CloudWatch/SNS observability and validation layer.

## Architecture Files

```text
architecture/
├── README.md
├── architecture-decisions.md
├── lab-09-architecture.png
└── lab-09-architecture.svg
```

Editable source:

```text
diagrams/lab-09-architecture.drawio
```

## Network Mapping

```text
us-east-2a
├── Public subnet  10.0.1.0/24
└── Private subnet 10.0.4.0/24

us-east-2b
├── Public subnet  10.0.3.0/24
└── Private subnet 10.0.2.0/24
```

The Auto Scaling Group evidence confirms the EC2 web tier uses the two public subnets. EFS Mount Targets and private database networking use the private subnet layer.

## Monitoring Layer

CloudWatch monitors the existing workload through native AWS metrics. Alarms feed Amazon SNS for operational notifications.

```text
EC2 / ALB / ASG / EFS / RDS
            │
            ▼
      Amazon CloudWatch
            │
            ▼
        Amazon SNS
```
