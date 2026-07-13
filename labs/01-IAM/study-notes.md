# AWS IAM - Study Notes

---

# What is AWS IAM?

AWS Identity and Access Management (IAM) is the AWS service responsible for managing identities and controlling access to AWS resources securely.

IAM allows administrators to define:

- Who can access AWS resources.
- What actions they can perform.
- Which resources they can access.
- Under which conditions access is granted.

IAM is a **Global AWS Service**, meaning its configuration applies across all AWS Regions.

---

# Core Components

## IAM Users

An IAM User represents a single person or application requiring access to AWS.

Examples:

- Cloud Administrator
- Developer
- DevOps Engineer
- CI/CD Pipeline

Best Practices

- One user per person.
- Never share credentials.
- Enable MFA.
- Avoid long-term Access Keys when possible.

---

## IAM Groups

Groups simplify permission management.

Instead of assigning permissions to every user individually, permissions are attached to a group.

Example

Administrators

├── Henry

├── John

├── Maria

Benefits

- Easier administration.
- Consistent permissions.
- Less configuration errors.

---

## IAM Policies

Policies are JSON documents that define permissions.

Policies determine:

- Allowed actions
- Denied actions
- Resources
- Conditions

Example

```json
{
  "Effect":"Allow",
  "Action":"ec2:*",
  "Resource":"*"
}
```

Types

- AWS Managed Policies
- Customer Managed Policies
- Inline Policies

---

## IAM Roles

Roles provide temporary permissions.

Unlike Users, Roles do not have permanent credentials.

Typical use cases

- EC2 accessing S3
- Lambda accessing DynamoDB
- Cross-account access

---

## Multi-Factor Authentication (MFA)

MFA adds a second authentication factor.

Authentication

Password

+

Temporary Code

Benefits

- Prevents credential theft.
- Protects privileged accounts.
- Recommended for every administrator.

---

# Authentication vs Authorization

Authentication

Who are you?

Authorization

What are you allowed to do?

---

# IAM Best Practices

✔ Never use the Root User.

✔ Enable MFA.

✔ Apply Least Privilege.

✔ Use IAM Groups.

✔ Prefer Roles over Access Keys.

✔ Rotate credentials.

✔ Monitor IAM activity using CloudTrail.

---

# AWS Managed Policies

AWS provides predefined policies.

Examples

AdministratorAccess

ReadOnlyAccess

PowerUserAccess

AmazonS3FullAccess

AmazonEC2FullAccess

Advantages

- Maintained by AWS.
- Easy to use.
- Frequently updated.

---

# Principle of Least Privilege

Users should receive only the permissions required to perform their tasks.

Never assign AdministratorAccess unless absolutely necessary.

---

# Root User

The Root User has unrestricted access.

Use it only for:

- Initial account setup.
- Billing configuration.
- Closing the AWS account.

For daily administration, always use IAM Users.

---

# Lab Summary

During this laboratory the following tasks were completed:

- Created an IAM administrative user.
- Created the Administrators group.
- Attached AdministratorAccess policy.
- Enabled Virtual MFA.
- Logged into AWS using IAM credentials.

---

# Key Concepts

| Concept | Description |
|----------|-------------|
| IAM | Identity management service |
| User | Individual identity |
| Group | Collection of users |
| Policy | Permission definition |
| Role | Temporary permissions |
| MFA | Additional authentication factor |
| Least Privilege | Minimum required permissions |
| Root User | AWS account owner |

---

# Interview Tip

A very common interview question is:

"What is the difference between an IAM User and an IAM Role?"

Expected answer:

- IAM Users have long-term credentials.
- IAM Roles provide temporary credentials through AWS STS.
- Roles are recommended for AWS services and cross-account access.

---

# References

https://docs.aws.amazon.com/IAM/

https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html

https://docs.aws.amazon.com/wellarchitected/
