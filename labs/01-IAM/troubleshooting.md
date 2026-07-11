# Troubleshooting – Amazon EC2

## Issue

SSH connection failed.

```
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions are too open.
```

---

## Cause

The private key (.pem) had Windows permissions that allowed other users to read it.

OpenSSH rejected the key for security reasons.

---

## Resolution

Removed inherited permissions.

Removed BUILTIN\Users.

Granted read access only to the owner.

---

## Lessons Learned

SSH requires private keys to be accessible only by the owner.

Improper permissions prevent authentication even when the key is correct.

---

## Best Practices

- Never upload private keys to GitHub.
- Restrict SSH to your public IP.
- Keep private keys outside the repository.
- Store SSH keys under ~/.ssh.
