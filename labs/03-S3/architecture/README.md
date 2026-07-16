# Amazon S3 Architecture

This directory contains the architecture diagram created for **Lab 03 – Amazon Simple Storage Service (S3)**.

The diagram represents the logical flow used to publish a static website from an Amazon S3 bucket and the main controls configured during the laboratory.

---

## Architecture Overview

The implemented architecture includes:

- AWS Account
- Amazon S3
- General-purpose S3 bucket
- Static website objects
- Static Website Hosting
- Bucket Policy with public read access
- S3 Website Endpoint
- Web Browser access
- Versioning
- SSE-S3 encryption
- Lifecycle management

---

## Architecture Flow

```text
Web Browser
     │
     ▼
Static Website Endpoint
     │
     ▼
Bucket Policy
Public read access
     │
     ▼
Static Website Hosting
     │
     ▼
Amazon S3 Bucket
henry-cloud-devops-portfolio-s3
     │
     ├── index.html
     └── css/style.css