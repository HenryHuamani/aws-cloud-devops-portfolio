# Troubleshooting

# Lab 07 – Amazon RDS

This document summarizes the issues encountered during the implementation of Amazon RDS for the NovaCommerce application and the solutions applied.

The goal is to provide a reference for diagnosing similar problems in future deployments.

---

# Issue 1 – SSH Connection Timeout

## Symptoms

Unable to establish an SSH connection to the EC2 instance.

```
ssh: connect to host <EC2_PUBLIC_IP> port 22:
Connection timed out
```

---

## Investigation

The following components were verified.

- EC2 instance status
- Internet Gateway
- Route Tables
- Network ACLs
- Security Groups

All appeared to be correctly configured.

---

## Root Cause

The Security Group allowed SSH only from the public IP returned by:

```bash
curl https://checkip.amazonaws.com
```

However, the actual source IP used by the ISP was different.

The discrepancy was confirmed using:

```bash
last -i
```

---

## Resolution

SSH access was temporarily opened using:

```
0.0.0.0/0
```

After successful validation, the correct public IP was identified and the Security Group rule was updated.

---

## Lesson Learned

Always validate the actual client IP instead of assuming the public IP reported by online services.

---

# Issue 2 – Unknown MySQL Server Host

## Symptoms

```
ERROR 2005 (HY000):
Unknown MySQL server host
```

---

## Investigation

The database endpoint was reviewed.

DNS resolution failed.

---

## Root Cause

The endpoint contained a typographical error.

The character:

```
o
```

was mistakenly written as:

```
0
```

---

## Resolution

The endpoint was copied directly from the Amazon RDS console.

DNS resolution immediately succeeded.

---

## Lesson Learned

Never manually type AWS endpoints.

Always copy them directly from the AWS Console.

---

# Issue 3 – MariaDB SSL Parameter

## Symptoms

```
mysql:
unknown variable 'ssl-mode=VERIFY_IDENTITY'
```

---

## Investigation

The installed client was:

```
MariaDB Client
```

instead of the official MySQL client.

---

## Root Cause

MariaDB uses different SSL parameters.

---

## Resolution

The connection command was updated to use:

```bash
--ssl-ca
--ssl-verify-server-cert
```

instead of:

```bash
--ssl-mode=VERIFY_IDENTITY
```

---

## Lesson Learned

Always verify client compatibility before using SSL options.

---

# Issue 4 – Missing SSL Certificate

## Symptoms

Unable to validate the encrypted connection.

---

## Root Cause

The Amazon RDS CA bundle had not been downloaded.

---

## Resolution

Downloaded the certificate:

```bash
curl -o global-bundle.pem \
https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

The connection was then successfully established.

---

## Lesson Learned

Encrypted communication requires trusted Certificate Authorities.

---

# Issue 5 – Database Connectivity Validation

## Validation Steps

Connectivity was verified through:

- DNS resolution
- TCP connectivity
- Security Groups
- SSL/TLS
- MySQL authentication

---

## Validation Commands

```bash
getent hosts <RDS_ENDPOINT>
```

```sql
STATUS;
```

```sql
SHOW DATABASES;
```

---

# Troubleshooting Workflow

Whenever Amazon RDS connectivity issues occur, validate the following components in order.

```
1. EC2 Status

↓

2. VPC

↓

3. Route Tables

↓

4. Security Groups

↓

5. DNS Resolution

↓

6. SSL Configuration

↓

7. MySQL Authentication

↓

8. SQL Validation
```

---

# Key Lessons

This laboratory reinforced several practical troubleshooting concepts.

- Validate infrastructure before applications.
- Verify Security Groups before Route Tables.
- Test DNS before MySQL authentication.
- Use SSL whenever possible.
- Copy AWS endpoints directly from the console.
- Verify client compatibility before enabling encryption.