
---

## `labs/03-S3/evidence/README.md`

Ajusta los nombres de la tabla para que coincidan exactamente con tus archivos reales.

```markdown
# Amazon S3 Laboratory Evidence

This directory contains the screenshots captured during **Lab 03 – Amazon Simple Storage Service (S3)**.

The evidence validates the creation, configuration, publication and lifecycle management of the S3 static website.

---

## Evidence List

| Image | Description |
|---|---|
| `01-s3-dashboard.png` | Amazon S3 console dashboard |
| `02-create-bucket.png` | Successful creation of the general-purpose bucket |
| `03-upload-files.png` | Website objects uploaded to the bucket |
| `04-access-denied.png` | Private object access before public permissions |
| `05-static-website-enabled.png` | Static Website Hosting enabled |
| `06-block-public-access-disabled.png` | Bucket-level public access configuration |
| `07-bucket-policy.png` | Bucket Policy allowing public object reads |
| `08-static-website-running.png` | Static website successfully published |
| `09-versioning-enabled.png` | Bucket Versioning enabled |
| `10-object-versions.png` | Multiple versions of an S3 object |
| `11-lifecycle-rule.png` | Enabled lifecycle rule for storage transitions |

---

## Laboratory Workflow

```text
Create S3 Bucket
        │
        ▼
Upload Website Files
        │
        ▼
Test Private Object Access
        │
        ▼
Enable Static Website Hosting
        │
        ▼
Configure Public Access
        │
        ▼
Apply Bucket Policy
        │
        ▼
Publish Static Website
        │
        ▼
Enable Versioning
        │
        ▼
Create Lifecycle Rule