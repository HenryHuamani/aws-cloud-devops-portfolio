# Amazon S3 Interview Questions

This document contains common technical interview questions related to **Amazon Simple Storage Service (Amazon S3)**.

---

# Basic Questions

## 1. What is Amazon S3?

Amazon S3 is AWS's object storage service designed for scalability, durability, high availability and security.

---

## 2. What is the difference between a Bucket and an Object?

A Bucket is a logical container.

An Object is the actual file stored inside the bucket.

---

## 3. What is an Object Key?

An Object Key is the unique identifier of an object inside a bucket.

Example:

```text
images/logo.png
```

---

## 4. Is Amazon S3 a file system?

No.

Amazon S3 is an object storage service, not a traditional file system.

Folders shown in the AWS Console are logical prefixes.

---

## 5. Can Amazon S3 host dynamic websites?

No.

Amazon S3 only hosts static content:

- HTML
- CSS
- JavaScript
- Images

Dynamic applications require services such as:

- Amazon EC2
- AWS Lambda
- Amazon ECS
- Amazon EKS

---

# Security Questions

## 6. What is Block Public Access?

A security feature that prevents accidental public exposure of S3 buckets and objects.

It is enabled by default.

---

## 7. What is a Bucket Policy?

A JSON document used to grant or deny permissions for bucket resources.

---

## 8. What permission allows public website access?

```text
s3:GetObject
```

Only read access should be granted.

---

## 9. Why should public write access be avoided?

Because anonymous users could:

- Upload malicious files
- Delete objects
- Modify website content

Only public read access should be allowed for static websites.

---

## 10. What is the difference between IAM Policies and Bucket Policies?

IAM Policies:

- Attached to users, groups or roles.
- Control what identities can do.

Bucket Policies:

- Attached directly to an S3 bucket.
- Control who can access bucket resources.

---

# Static Website Hosting

## 11. What is Static Website Hosting?

An Amazon S3 feature that allows a bucket to serve static web content.

---

## 12. What is the difference between Object URL and Website Endpoint?

Object URL

- Accesses a single object.
- Respects object permissions.

Website Endpoint

- Serves the entire static website.
- Uses index and error documents.

---

## 13. Why does the Website Endpoint use HTTP instead of HTTPS?

Native Amazon S3 Website Endpoints only support HTTP.

HTTPS is typically implemented using:

- Amazon CloudFront
- AWS Certificate Manager (ACM)

---

# Versioning

## 14. What is Versioning?

Versioning stores multiple versions of the same object.

Benefits:

- Restore previous versions.
- Recover deleted files.
- Prevent accidental overwrites.

---

## 15. Can Versioning be disabled?

Versioning can be suspended.

Existing versions remain stored.

---

# Lifecycle Rules

## 16. What is a Lifecycle Rule?

A rule that automatically transitions or expires objects based on age.

---

## 17. Why use Lifecycle Rules?

Benefits:

- Reduce storage costs.
- Automate storage management.
- Archive old data.

---

## 18. Which storage classes were used in this laboratory?

- Standard
- Standard-IA
- Glacier Flexible Retrieval
- Glacier Deep Archive

---

# Encryption

## 19. What encryption method was used?

SSE-S3

AWS automatically manages the encryption keys.

---

## 20. What other server-side encryption options exist?

- SSE-S3
- SSE-KMS
- SSE-C

---

# Architecture Questions

## 21. Why is Amazon S3 considered highly durable?

Amazon S3 is designed for **11 nines (99.999999999%)** of durability by storing redundant copies of objects across multiple Availability Zones within an AWS Region.

---

## 22. Why use Amazon S3 instead of Amazon EC2 to host a static website?

Advantages:

- Lower cost.
- No server management.
- High scalability.
- High durability.
- Native static website hosting.

---

## 23. What would you improve in a production environment?

Instead of exposing the bucket publicly:

- Amazon CloudFront
- Origin Access Control (OAC)
- AWS Certificate Manager
- Route 53
- AWS WAF

---

# Best Practices

- Enable Versioning.
- Enable server-side encryption.
- Apply Least Privilege.
- Use Lifecycle Rules.
- Avoid public write permissions.
- Use Bucket Policies instead of ACLs.
- Use CloudFront for production workloads.

---

# Summary

After completing this laboratory you should be able to explain:

- How Amazon S3 stores objects.
- How a static website is published.
- How Bucket Policies work.
- How Versioning protects data.
- How Lifecycle Rules optimize storage.
- How S3 fits into modern cloud architectures.