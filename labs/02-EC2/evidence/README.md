# Amazon EC2 Laboratory Evidence

This directory contains the screenshots captured during **Lab 02 – Amazon Elastic Compute Cloud (EC2)**.

These images document each step performed during the laboratory and provide visual evidence of the successful implementation.

---

# Screenshots

| Image | Description |
|--------|-------------|
| `01-ec2-dashboard.png` | Amazon EC2 Dashboard |
| `02-instance-details.png` | EC2 Instance Details |
| `03-security-group.png` | Security Group Configuration |
| `04-connect-error.png` | Initial SSH Connection Attempt |
| `05-ssh-permissions-error.png` | Windows Private Key Permission Issue |
| `06-ssh-success.png` | Successful SSH Connection to Ubuntu |

---

# Laboratory Workflow

```text
Launch EC2 Instance
        │
        ▼
Configure Security Group
        │
        ▼
Generate Key Pair
        │
        ▼
SSH Connection Attempt
        │
        ▼
Resolve Windows Permission Issue
        │
        ▼
Successful Linux Login
```

---

# Lessons Learned

During this laboratory the following concepts were validated:

- EC2 instance deployment
- Security Group configuration
- SSH authentication using Key Pair
- Windows OpenSSH permission requirements
- Secure remote administration

---

# Related Documentation

- README.md
- study-notes.md
- commands.md
- interview-questions.md
- troubleshooting.md
