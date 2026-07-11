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

````

---

## `comandos.md`

```markdown
# Commands and Technical References – AWS IAM

This laboratory was mainly completed through the AWS Management Console.

No AWS CLI commands were required.

## Useful AWS CLI Commands

### Display the current authenticated identity

```bash
aws sts get-caller-identity
````

### List IAM users

```bash
aws iam list-users
```

### List IAM groups

```bash
aws iam list-groups
```

### List users belonging to a group

```bash
aws iam get-group --group-name Administrators
```

### List policies attached to a group

```bash
aws iam list-attached-group-policies --group-name Administrators
```

### List MFA devices

```bash
aws iam list-mfa-devices --user-name henry.admin
```

## Important Security Warning

Never publish the following values in GitHub:

* AWS access key ID.
* AWS secret access key.
* Session token.
* Passwords.
* MFA recovery codes.
* Account identifiers when unnecessary.

````

---

## `preguntas.md`

```markdown
# Interview Questions – AWS IAM

## 1. What is AWS IAM?

IAM is the AWS service used to manage identities, authentication and permissions for access to AWS resources.

## 2. What is the difference between the root user and an IAM user?

The root user has unrestricted access to the AWS account and should only be used for exceptional account-level tasks.

An IAM user is created for daily access and receives only the permissions required for its responsibilities.

## 3. What is the difference between an IAM user and an IAM role?

An IAM user normally represents a person or application with long-term credentials.

An IAM role provides temporary permissions and is assumed by users, applications or AWS services.

## 4. What is an IAM policy?

An IAM policy is a JSON document that defines allowed or denied actions over AWS resources.

## 5. Why should permissions be assigned through groups?

Groups simplify administration and ensure that users with similar responsibilities receive consistent permissions.

## 6. What is MFA?

Multi-Factor Authentication adds a second authentication factor in addition to the password.

## 7. What is the principle of least privilege?

It consists of granting only the minimum permissions necessary to perform a specific task.

## 8. What is an explicit deny?

An explicit deny is a policy statement that blocks an action and takes precedence over an allow statement.

## 9. Are IAM resources regional?

IAM is a global AWS service. Users, groups, roles and policies are not created within a specific AWS region.

## 10. When should an IAM role be used instead of access keys?

A role should be used whenever an AWS service or application requires temporary access to AWS resources, avoiding permanent credentials.

