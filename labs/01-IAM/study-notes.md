## `notas.md`

````markdown
# Notes – AWS IAM

## What is IAM?

AWS Identity and Access Management (IAM) is the AWS service used to manage identities, authentication and permissions for access to AWS resources.

IAM allows administrators to define:

- Who can access AWS.
- Which resources can be accessed.
- Which actions can be performed.
- Under which conditions access is allowed.

## Main IAM Components

### Root User

The root user is created when the AWS account is registered.

It has full access to all AWS services and account settings.

The root user should only be used for exceptional administrative tasks, such as:

- Account recovery.
- Billing configuration.
- Closing the AWS account.
- Managing certain global security settings.

It should not be used for daily administration.

### IAM User

An IAM user represents a person or application that requires access to AWS.

An IAM user may have:

- Console access.
- Programmatic access.
- Password.
- Access keys.
- Permissions assigned directly or through groups.

### IAM Group

An IAM group is a collection of IAM users.

Groups simplify permissions management because permissions can be assigned to the group instead of individually to each user.

Example:

```text
Administrators
Developers
Auditors
ReadOnlyUsers
````

### IAM Policy

An IAM policy is a JSON document that defines permissions.

A policy specifies:

* Effect: Allow or Deny.
* Actions.
* Resources.
* Optional conditions.

Example structure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}
```

### IAM Role

An IAM role is an identity with permissions that can be assumed temporarily.

Roles are commonly used by:

* AWS services.
* Applications.
* Federated users.
* Resources such as EC2 instances and Lambda functions.

Unlike IAM users, roles do not normally use permanent credentials.

## Authentication vs Authorization

### Authentication

Verifies who the user is.

Examples:

* Username and password.
* MFA.
* Access key.
* Federated identity.

### Authorization

Determines what the authenticated identity is allowed to do.

Authorization is controlled through IAM policies.

## Multi-Factor Authentication

MFA adds an additional authentication factor.

It protects the account even if the password is compromised.

Recommended usage:

* Root account.
* Administrative IAM users.
* Privileged users.

## Principle of Least Privilege

The principle of least privilege means granting only the permissions required to complete a task.

Example:

A user who only needs to read files from S3 should not receive full administrative permissions.

## Laboratory Decisions

For this introductory laboratory, the managed policy `AdministratorAccess` was assigned to the `Administrators` group.

This configuration is acceptable for an isolated learning environment, but in production environments permissions should be more restrictive and aligned with the user's responsibilities.
