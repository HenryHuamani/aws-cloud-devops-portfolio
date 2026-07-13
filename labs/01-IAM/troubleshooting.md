# AWS IAM - Troubleshooting Guide

This document describes the most common issues encountered while working with **AWS Identity and Access Management (IAM)** and the solutions applied during this laboratory.

---

# Issue 1 - Unable to Sign in with IAM User

## Symptoms

- Login fails.
- "Invalid username or password."
- "User does not exist."

## Possible Causes

- Incorrect account alias.
- Incorrect account ID.
- Wrong username.
- Incorrect password.

## Resolution

- Verify the AWS Account ID.
- Confirm the IAM username.
- Reset the password if necessary.
- Use the correct AWS Sign-in URL.

---

# Issue 2 - Access Denied

## Symptoms

```
AccessDenied
```

or

```
You are not authorized to perform this operation.
```

## Possible Causes

- Missing IAM permissions.
- Policy not attached.
- User not assigned to the correct group.

## Resolution

- Verify attached policies.
- Check group membership.
- Confirm policy inheritance.

---

# Issue 3 - User Cannot Access AWS Console

## Symptoms

The user can authenticate but cannot access AWS services.

## Possible Causes

- Console access disabled.
- Incorrect permissions.
- Missing IAM policy.

## Resolution

- Enable console access.
- Attach the required policy.
- Verify group permissions.

---

# Issue 4 - MFA Authentication Failed

## Symptoms

The MFA code is rejected.

## Possible Causes

- Incorrect device time.
- Wrong MFA application.
- Incorrect QR code configuration.

## Resolution

- Synchronize the mobile device time.
- Reconfigure the Virtual MFA device.
- Verify the generated authentication code.

---

# Issue 5 - Root User Used for Daily Administration

## Problem

Using the AWS Root User for daily tasks increases security risks.

## Resolution

Create an IAM administrative user and enable MFA.

Use the Root User only for:

- Initial account setup.
- Billing management.
- Account recovery.

---

# Issue 6 - Permissions Not Applied

## Symptoms

The user belongs to a group but still cannot access AWS resources.

## Possible Causes

- Policy not attached.
- Explicit Deny.
- Permission propagation delay.

## Resolution

- Verify attached policies.
- Check for explicit Deny statements.
- Wait a few minutes and test again.

---

# Issue 7 - AdministratorAccess Not Working

## Symptoms

The user still receives permission errors.

## Possible Causes

- User not added to the Administrators group.
- Policy attached to the wrong group.
- Session not refreshed.

## Resolution

- Verify group membership.
- Confirm AdministratorAccess is attached to the correct group.
- Sign out and sign in again.

---

# Common IAM Errors

| Error | Description |
|--------|-------------|
| AccessDenied | Missing permissions |
| InvalidClientTokenId | Invalid credentials |
| UnauthorizedOperation | User lacks authorization |
| Login Failed | Invalid username or password |
| MFA Failed | Invalid authentication code |

---

# Security Recommendations

- Enable MFA for all administrative users.
- Never use the Root User for daily work.
- Follow the Principle of Least Privilege.
- Use IAM Groups to simplify permission management.
- Prefer IAM Roles instead of long-term Access Keys.
- Enable CloudTrail for auditing.

---

# Lessons Learned

During this laboratory the following concepts were reinforced:

- IAM is a Global AWS service.
- Permissions are controlled using Policies.
- Groups simplify permission management.
- MFA significantly improves account security.
- Least Privilege is a fundamental AWS security principle.
- AWS Managed Policies accelerate secure administration.

---

# Laboratory Outcome

Successfully completed:

- IAM User creation.
- IAM Group creation.
- AdministratorAccess policy assignment.
- Virtual MFA configuration.
- AWS Console authentication.
