# Amazon S3 Commands

This document summarizes the AWS Management Console operations performed during **Lab 03 – Amazon Simple Storage Service (S3)**.

---

# 1. Create Bucket

Amazon S3

→ Buckets

→ Create Bucket

Configuration:

- Bucket Name:
  - henry-cloud-devops-portfolio-s3
- Region:
  - US East (Ohio)
- Bucket Type:
  - General Purpose
- ACLs:
  - Disabled
- Object Ownership:
  - Bucket owner enforced
- Default Encryption:
  - SSE-S3

---

# 2. Upload Website Files

Bucket

→ Objects

→ Upload

Files:

```text
index.html

css/
    style.css
```

---

# 3. Enable Static Website Hosting

Bucket

→ Properties

→ Static Website Hosting

Configuration:

```text
Enable

Hosting Type:
Host a Static Website

Index Document:
index.html

Error Document:
error.html
```

---

# 4. Configure Public Access

Bucket

→ Permissions

→ Block Public Access

Disabled:

- Block all public access

---

# 5. Bucket Policy

Bucket

→ Permissions

→ Bucket Policy

```json
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicReadForWebsite",
      "Effect":"Allow",
      "Principal":"*",
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::henry-cloud-devops-portfolio-s3/*"
    }
  ]
}
```

---

# 6. Website Endpoint

```text
http://henry-cloud-devops-portfolio-s3.s3-website.us-east-2.amazonaws.com
```

---

# 7. Enable Versioning

Bucket

→ Properties

→ Bucket Versioning

```text
Enabled
```

---

# 8. Lifecycle Rule

Bucket

→ Management

→ Lifecycle Rules

Rule:

```text
Move-Old-Objects
```

Transitions:

| Days | Storage Class |
|------|---------------|
| 30 | Standard-IA |
| 90 | Glacier Flexible Retrieval |
| 365 | Glacier Deep Archive |

---

# Services Used

- Amazon S3
- AWS IAM

---

# AWS Features Used

- Static Website Hosting
- Bucket Policy
- Block Public Access
- SSE-S3 Encryption
- Versioning
- Lifecycle Rules