# Amazon S3 Study Notes

These notes summarize the most important concepts learned during **Lab 03 – Amazon Simple Storage Service (Amazon S3)**.

---

# What is Amazon S3?

Amazon Simple Storage Service (Amazon S3) is AWS's object storage service designed to provide scalability, high durability, availability and security.

Amazon S3 stores data as objects inside buckets.

---

# Core Components

## Bucket

A bucket is a logical container used to store objects.

Characteristics:

- Globally unique name
- Created in one AWS Region
- Stores unlimited objects

---

## Object

An object is a file stored inside an S3 bucket.

An object consists of:

- Data
- Metadata
- Object Key
- Version ID (if Versioning is enabled)

---

## Object Key

The Object Key is the unique identifier of an object inside a bucket.

Example:

```text
images/logo.png
```

---

# Storage Classes

Amazon S3 offers multiple storage classes depending on access frequency.

| Storage Class | Use Case |
|--------------|----------|
| Standard | Frequently accessed data |
| Standard-IA | Infrequently accessed data |
| Glacier Instant Retrieval | Archived data with immediate retrieval |
| Glacier Flexible Retrieval | Long-term archive |
| Glacier Deep Archive | Lowest-cost long-term storage |

---

# Static Website Hosting

Amazon S3 can host static websites composed of:

- HTML
- CSS
- JavaScript
- Images

Static website hosting does not support server-side code.

---

# Object URL vs Website Endpoint

## Object URL

Provides direct access to a single object.

Example:

```text
https://bucket.s3.amazonaws.com/index.html
```

Requires object permissions.

---

## Website Endpoint

Provides access to the static website.

Example:

```text
http://bucket.s3-website-us-east-2.amazonaws.com
```

Used only when Static Website Hosting is enabled.

---

# Bucket Policy

A Bucket Policy is a JSON document that defines permissions for bucket resources.

Example permission:

```text
s3:GetObject
```

Allows users to read objects.

---

# Block Public Access

AWS blocks public access by default.

This protects buckets against accidental exposure.

For static website hosting, public read access must be configured intentionally.

---

# Versioning

Versioning stores multiple versions of the same object.

Benefits:

- Recover deleted files
- Restore previous versions
- Protect against accidental overwrites

---

# Lifecycle Rules

Lifecycle Rules automatically manage object storage.

Typical lifecycle:

```text
Day 0
Standard

↓

30 Days

↓

Standard-IA

↓

90 Days

↓

Glacier Flexible Retrieval

↓

365 Days

↓

Glacier Deep Archive
```

Benefits:

- Cost optimization
- Automated storage management
- Long-term archiving

---

# Default Encryption

Amazon S3 supports server-side encryption.

This laboratory uses:

```text
SSE-S3
```

AWS manages the encryption keys automatically.

---

# Best Practices

- Enable Versioning.
- Enable default encryption.
- Apply Least Privilege.
- Use Lifecycle Rules.
- Avoid public write permissions.
- Use Bucket Policies instead of ACLs.
- Monitor storage costs.

---

# Skills Learned

- Amazon S3
- Bucket Management
- Static Website Hosting
- Bucket Policies
- Public Access Control
- Versioning
- Lifecycle Management
- Storage Classes
- Website Deployment
- Cost Optimization

---

# Summary

After completing this laboratory, you should understand:

- How Amazon S3 stores data.
- How static websites are published.
- How access permissions are managed.
- How Versioning protects objects.
- How Lifecycle Rules optimize storage costs.
- How Amazon S3 can be used as a static website hosting platform.