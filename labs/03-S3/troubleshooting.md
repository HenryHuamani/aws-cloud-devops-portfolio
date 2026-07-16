# Amazon S3 Troubleshooting

This document summarizes the most common issues encountered during **Lab 03 – Amazon Simple Storage Service (Amazon S3)** and their corresponding solutions.

---

# Issue 1

## Static website returns "Access Denied"

### Symptoms

The website endpoint displays:

```text
Access Denied
```

### Cause

The bucket is private.

Static Website Hosting is enabled, but the bucket policy does not allow public read access.

### Solution

- Disable Block Public Access (only for this laboratory).
- Create a Bucket Policy allowing:

```text
s3:GetObject
```

for:

```text
arn:aws:s3:::bucket-name/*
```

---

# Issue 2

## CSS is not loading

### Symptoms

The HTML page loads but appears without styles.

### Cause

Possible causes:

- Wrong folder structure
- Incorrect CSS path
- CSS file was not uploaded

### Solution

Verify:

```text
Bucket

index.html

css/
    style.css
```

and inside HTML:

```html
<link rel="stylesheet" href="css/style.css">
```

---

# Issue 3

## Website Endpoint not working

### Symptoms

The endpoint returns an error.

### Cause

Static Website Hosting is disabled.

### Solution

Go to:

```text
Bucket

↓

Properties

↓

Static Website Hosting

↓

Enable
```

---

# Issue 4

## Object URL returns Access Denied

### Symptoms

Opening:

```text
https://bucket.s3.amazonaws.com/index.html
```

returns:

```text
Access Denied
```

### Cause

The object is private.

### Solution

This is expected unless the object is publicly readable through the bucket policy.

---

# Issue 5

## Bucket Policy validation error

### Symptoms

AWS rejects the policy.

### Cause

Usually:

- Invalid JSON
- Incorrect bucket ARN
- Missing quotation marks

### Solution

Validate:

- Bucket name
- JSON syntax
- Resource ARN

Example:

```text
arn:aws:s3:::bucket-name/*
```

---

# Issue 6

## Versioning not showing previous versions

### Symptoms

Only one object appears.

### Cause

Versioning was enabled after uploading the object.

### Solution

Upload the object again after enabling Versioning.

Then activate:

```text
Show Versions
```

inside the Objects tab.

---

# Issue 7

## Lifecycle Rule not executing immediately

### Symptoms

Objects remain in Standard storage.

### Cause

Lifecycle Rules are asynchronous.

AWS evaluates them periodically.

### Solution

Wait for AWS to process the lifecycle transition.

This behavior is normal.

---

# Issue 8

## Browser shows "Not Secure"

### Symptoms

The website displays:

```text
Not Secure
```

### Cause

Amazon S3 Website Endpoints only support HTTP.

### Solution

Use:

- Amazon CloudFront
- AWS Certificate Manager (ACM)

to enable HTTPS.

---

# Lessons Learned

Most Amazon S3 issues are related to:

- Permissions
- Bucket Policies
- Public Access configuration
- Incorrect object paths
- Static Website Hosting configuration

Understanding these concepts greatly simplifies troubleshooting.