# Interview Questions

# Lab 07 – Amazon RDS

This document contains technical interview questions related to Amazon RDS, database design, networking, security, and cloud architecture.

---

# Amazon RDS Fundamentals

## 1. What is Amazon RDS?

Amazon Relational Database Service (Amazon RDS) is a fully managed database service that automates provisioning, backups, patching, monitoring, scaling, and maintenance of relational databases.

---

## 2. Which database engines does Amazon RDS support?

Amazon RDS supports:

- MySQL
- PostgreSQL
- MariaDB
- Oracle
- Microsoft SQL Server
- Amazon Aurora

---

## 3. Why use Amazon RDS instead of installing MySQL on EC2?

Amazon RDS reduces operational overhead by managing backups, software updates, monitoring, storage, and recovery.

Installing MySQL on EC2 requires manual administration.

---

## 4. Is Amazon RDS serverless?

Traditional Amazon RDS is not serverless.

Amazon Aurora Serverless is the serverless database offering.

---

## 5. What administrative tasks are managed by Amazon RDS?

Amazon RDS manages:

- Operating system
- Database installation
- Software patching
- Automated backups
- Monitoring
- Storage
- Maintenance

---

# Networking

## 6. Why was Amazon RDS deployed in private subnets?

To prevent direct Internet access and reduce the attack surface.

Only trusted resources inside the VPC should communicate with the database.

---

## 7. What is a DB Subnet Group?

A DB Subnet Group is a collection of subnets that Amazon RDS uses when deploying database instances.

It should contain subnets in multiple Availability Zones.

---

## 8. Can Amazon RDS be deployed in public subnets?

Yes, but it is not recommended for production workloads.

Production databases should remain private whenever possible.

---

## 9. Why disable Public Access?

Disabling Public Access prevents external clients from connecting directly to the database.

---

## 10. How does EC2 communicate with Amazon RDS?

Through private networking inside the VPC using Security Groups.

---

# Security

## 11. Why use Security Groups instead of public IP restrictions?

Security Groups allow communication between AWS resources without relying on changing public IP addresses.

---

## 12. What is the Principle of Least Privilege?

Grant only the permissions required for a resource to perform its function.

---

## 13. Why encrypt database traffic?

To protect credentials and sensitive business data during transmission.

---

## 14. What protocol protects communication with Amazon RDS?

SSL/TLS.

---

## 15. What happens if SSL is disabled?

Traffic can be transmitted without encryption, increasing security risks.

---

# Database Design

## 16. Why normalize a relational database?

Normalization reduces redundancy and improves consistency.

---

## 17. What is a Primary Key?

A column that uniquely identifies each record.

---

## 18. What is a Foreign Key?

A column that references the Primary Key of another table.

It enforces referential integrity.

---

## 19. Why create a separate Order Details table?

One order can contain multiple products.

The Order Details table resolves the many-to-many relationship between orders and products.

---

## 20. Why separate Inventory from Products?

Inventory records stock movements, while Products store product information.

This separation improves traceability.

---

## 21. Why separate Payments from Orders?

An order and its payment have different business lifecycles.

Payments may be pending, approved, or rejected independently of the order.

---

# SQL

## 22. What are CRUD operations?

CRUD stands for:

- Create
- Read
- Update
- Delete

---

## 23. Which SQL command inserts new records?

INSERT.

---

## 24. Which SQL command retrieves data?

SELECT.

---

## 25. Which SQL command modifies existing data?

UPDATE.

---

## 26. Which SQL command removes records?

DELETE.

---

## 27. What is a JOIN?

A JOIN combines data from multiple related tables.

---

## 28. Why use Views?

Views simplify complex SQL queries and improve reporting.

---

# Troubleshooting

## 29. How would you troubleshoot an EC2 that cannot connect to Amazon RDS?

Verify:

- Security Groups
- VPC
- Route Tables
- DNS resolution
- Database endpoint
- SSL configuration

---

## 30. What causes "Unknown MySQL server host"?

Usually:

- Incorrect endpoint
- DNS resolution failure
- Typographical errors

---

## 31. What command verifies DNS resolution?

```bash
getent hosts <RDS_ENDPOINT>
```

---

## 32. How do you verify an encrypted database connection?

Execute:

```sql
STATUS;
```

Verify that SSL is active.

---

## 33. Why did MariaDB reject the parameter --ssl-mode?

Because that parameter belongs to the official MySQL client.

MariaDB uses different SSL parameters.

---

# Architecture

## 34. Why shouldn't application servers store business data locally?

Auto Scaling instances are ephemeral.

When an instance terminates, local storage is lost.

---

## 35. Why reuse the VPC instead of creating a new one?

Infrastructure reuse reduces complexity and reflects real-world AWS architectures.

---

## 36. What architectural pattern was implemented?

A three-tier architecture.

```
Presentation

↓

Application

↓

Database
```

---

## 37. Why separate compute from persistence?

Application servers can scale independently while the database remains persistent.

---

## 38. What AWS service provides persistent relational storage?

Amazon RDS.

---

# Best Practices

## 39. Should databases have public IP addresses?

Generally, no.

Databases should remain inside private subnets.

---

## 40. What AWS best practices were applied in this laboratory?

- Private subnets
- Security Groups
- SSL/TLS
- Least Privilege
- Infrastructure reuse
- Managed services
- Relational database normalization