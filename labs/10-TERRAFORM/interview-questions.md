# 🎤 Lab 10 — Terraform Interview Questions

This document contains technical interview questions based on the infrastructure implemented in Lab 10.

The objective is not only to understand Terraform concepts, but to be able to explain the architecture, implementation decisions, troubleshooting process, security considerations, and production improvements during Cloud, DevOps, Infrastructure, and SRE interviews.

---

# 1. Terraform Fundamentals

## Q1. What is Terraform and why would you use it?

Terraform is an Infrastructure as Code tool that allows infrastructure to be defined declaratively.

Instead of manually creating infrastructure through the AWS Console, Terraform allows infrastructure to be represented as version-controlled code.

The main benefits include:

- reproducibility
- automation
- consistency
- version control
- infrastructure review
- reusable modules
- reduced manual configuration

In this laboratory, I used Terraform to create an AWS VPC architecture including public and private subnets, route tables, route table associations, and an Internet Gateway.

---

## Q2. What is the difference between `terraform init`, `validate`, `plan`, and `apply`?

`terraform init` initializes the Terraform working directory and downloads providers and modules.

`terraform validate` checks whether the configuration is syntactically valid and internally consistent.

`terraform plan` compares the desired configuration with the current state and infrastructure and displays the proposed changes.

`terraform apply` executes those changes.

My workflow was:

```text
terraform init
      ↓
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review
      ↓
terraform apply
```

---

## Q3. Why should you review `terraform plan` before applying?

Because Terraform may create, modify, replace, or destroy infrastructure.

Reviewing the plan allows an engineer to identify unexpected changes before they reach the cloud environment.

For example, the initial plan for this laboratory showed:

```text
Plan: 13 to add, 0 to change, 0 to destroy.
```

I reviewed that before applying it.

---

# 2. Terraform State

## Q4. What is Terraform state?

Terraform state maintains Terraform's mapping between configuration and real infrastructure.

Conceptually:

```text
Terraform Configuration
        ↕
Terraform State
        ↕
AWS Infrastructure
```

Terraform uses state to understand which resources it manages and determine required changes.

---

## Q5. Would you commit `terraform.tfstate` to GitHub?

No.

Terraform state can contain infrastructure metadata and potentially sensitive information.

In this repository I excluded:

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
tfplan
*.tfvars
```

For production workloads I would use a secure remote state architecture instead of committing state to source control.

---

## Q6. What would you use for Terraform state in AWS production environments?

A common architecture is remote state stored in Amazon S3 with appropriate:

- encryption
- versioning
- IAM access controls
- state locking strategy

The exact locking design depends on the Terraform version and organizational implementation.

The objective is to prevent conflicting state operations and protect infrastructure state.

---

# 3. Terraform Modules

## Q7. Why did you create a VPC module instead of putting everything in `main.tf`?

To separate reusable infrastructure logic from environment-specific configuration.

The laboratory uses:

```text
terraform/
├── environments/
│   └── dev/
│
└── modules/
    └── vpc/
```

`environments/dev` represents the environment configuration.

`modules/vpc` contains reusable VPC infrastructure logic.

This makes the code easier to maintain and prepares the repository for additional environments such as staging and production.

---

## Q8. What is the difference between a root module and a child module?

The root module is the Terraform configuration from which Terraform is executed.

In this laboratory:

```text
terraform/environments/dev
```

is the root module.

The reusable VPC module:

```text
terraform/modules/vpc
```

is a child module called by the root module.

---

## Q9. Why use variables in Terraform modules?

Variables make modules configurable and reusable.

Instead of hardcoding values such as:

```text
10.20.0.0/16
```

everywhere, the value can be provided by the calling environment.

This allows the same module to be reused with different network configurations.

---

## Q10. Why use outputs?

Outputs expose useful information from a module or root configuration.

In this laboratory I exposed values such as:

```text
vpc_id
public_subnet_ids
private_subnet_ids
internet_gateway_id
public_route_table_id
private_route_table_id
```

These can later be consumed by other modules, automation, CI/CD pipelines, or operators.

---

# 4. AWS Networking

## Q11. Explain the VPC architecture you created.

The laboratory creates a VPC in:

```text
us-east-2
```

using:

```text
10.20.0.0/16
```

The architecture contains four subnets distributed across two Availability Zones:

```text
VPC 10.20.0.0/16
│
├── us-east-2a
│   ├── Public  10.20.1.0/24
│   └── Private 10.20.11.0/24
│
└── us-east-2b
    ├── Public  10.20.2.0/24
    └── Private 10.20.12.0/24
```

The public subnets are associated with a public route table that contains a default route to the Internet Gateway.

The private subnets use a separate private route table.

---

## Q12. What makes a subnet public?

A subnet is not public simply because it is called "public."

Its routing configuration is one of the critical factors.

In this architecture, the public route table contains:

```text
0.0.0.0/0 → Internet Gateway
```

and the public subnets are associated with that route table.

For an EC2 instance to communicate directly with the Internet, other requirements such as appropriate IP addressing and security configuration must also be satisfied.

---

## Q13. What makes the other subnets private?

The private subnets are associated with a different route table that does not contain a default route directly to the Internet Gateway.

Therefore, they do not have the same direct Internet routing path as the public subnets.

---

## Q14. Can instances in your private subnets currently access the Internet?

Not through a NAT Gateway in the architecture implemented by this lab.

The current architecture intentionally establishes the networking foundation but does not yet implement NAT-based outbound Internet access for private workloads.

For controlled outbound IPv4 Internet access from private subnets, a common production design would introduce NAT Gateway connectivity through public subnets and configure the private route table accordingly.

---

## Q15. Why use multiple Availability Zones?

To improve availability and fault isolation.

The architecture distributes subnets across:

```text
us-east-2a
us-east-2b
```

This provides the network foundation for workloads that can later be distributed across multiple Availability Zones.

---

# 5. Routing

## Q16. What routes exist in your public route table?

The validation showed:

```text
10.20.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

The local route allows communication within the VPC CIDR.

The default route sends other IPv4 traffic toward the Internet Gateway.

---

## Q17. Why does AWS automatically have a local route?

The local route enables routing between resources within the VPC CIDR according to the VPC networking model and applicable security controls.

For this VPC:

```text
10.20.0.0/16 → local
```

is the local route.

---

## Q18. Why use separate public and private route tables?

Because public and private workloads normally require different routing behavior.

Public subnets may require Internet Gateway routing.

Private subnets should not receive the same direct Internet Gateway route.

Separating route tables provides explicit network segmentation and allows each tier to evolve independently.

---

# 6. Idempotency and Drift

## Q19. What is idempotency in Terraform?

It means that after infrastructure reaches the desired state, executing Terraform again without changing the configuration should not continuously modify resources.

After deployment I ran:

```powershell
terraform plan
```

and Terraform returned:

```text
No changes. Your infrastructure matches the configuration.
```

This was an important validation of the laboratory.

---

## Q20. What is infrastructure drift?

Drift occurs when the actual infrastructure differs from what Terraform expects.

For example, if someone manually changes a Terraform-managed resource through the AWS Console, the real infrastructure may no longer match the Terraform configuration.

Running:

```powershell
terraform plan
```

can help identify those differences.

---

## Q21. Would you manually modify Terraform-managed resources in AWS Console?

Normally, no.

Uncontrolled manual changes can create configuration drift.

Emergency changes may occasionally be necessary operationally, but they should subsequently be reconciled with the Infrastructure as Code configuration and normal change-management process.

---

# 7. Troubleshooting

## Q22. What problems did you encounter during this laboratory?

Several real problems occurred:

1. Terraform was not initially available in the Windows PATH.
2. AWS CLI initially had no valid credentials.
3. An AWS login session expired.
4. Terraform was accidentally executed from the wrong directory.
5. A PowerShell navigation command was constructed incorrectly.
6. Root Terraform outputs were initially missing.
7. A saved Terraform plan became stale after state changed.
8. Terraform runtime/state files had to be excluded from Git.

Each problem was documented in:

```text
troubleshooting.md
```

including root cause, resolution, and lessons learned.

---

## Q23. Why did `terraform plan` fail even though `terraform validate` succeeded?

Because they validate different things.

`terraform validate` checks the Terraform configuration itself.

`terraform plan` using the AWS provider needs to interact with AWS APIs and therefore requires valid AWS credentials.

My AWS login session had expired, so the configuration was valid but Terraform could not authenticate to AWS.

---

## Q24. What does "Saved plan is stale" mean?

It means the Terraform state changed after the saved plan was generated.

A plan represents infrastructure state at a particular moment.

After applying that plan, the state changed, so trying to reuse the same plan was no longer valid.

The solution is to generate a new plan.

---

# 8. AWS CLI Validation

## Q25. Why did you use AWS CLI if Terraform already said the apply succeeded?

To independently validate the real AWS infrastructure.

Terraform confirmed the deployment from the IaC perspective.

AWS CLI confirmed resources directly through AWS APIs.

I validated:

- VPC
- CIDR
- subnet CIDRs
- Availability Zones
- public IP behavior
- route tables
- subnet associations
- Internet Gateway route

This provided stronger technical evidence than relying exclusively on Terraform output.

---

## Q26. How would you validate the VPC using AWS CLI?

For example:

```powershell
aws ec2 describe-vpcs `
  --region us-east-2 `
  --filters "Name=tag:Project,Values=portfolio-terraform"
```

In the laboratory I also used JMESPath queries and table output to make validation easier to review and document.

---

# 9. Production Architecture

## Q27. Is this architecture production-ready?

Not yet.

It is a strong networking and Terraform foundation, but production environments would require additional capabilities depending on workload requirements.

Examples include:

- remote Terraform state
- state locking
- stronger IAM automation
- NAT architecture where required
- security groups
- VPC endpoints
- centralized logging
- monitoring
- CI/CD validation
- security scanning
- multiple environments
- backup and recovery strategy
- workload deployment
- cost controls

The purpose of this laboratory is to establish the IaC foundation that later projects will extend.

---

## Q28. What would you implement next?

My next priorities would include:

```text
Remote Terraform State
        ↓
Security Controls
        ↓
Compute Workloads
        ↓
Load Balancing
        ↓
Auto Scaling
        ↓
Monitoring
        ↓
CI/CD
        ↓
Security Scanning
```

For this portfolio, however, some of these capabilities are also demonstrated progressively in separate laboratories so that each engineering concept can be documented clearly.

---

## Q29. Would you always deploy a NAT Gateway?

No.

A NAT Gateway has cost and architectural implications.

Whether it is required depends on whether private workloads need outbound Internet connectivity.

For some architectures, AWS service access can instead be provided through VPC endpoints, reducing dependency on Internet/NAT paths for supported AWS services.

The design should be based on workload requirements, security, availability, and cost.

---

# 10. Senior-Level Questions

## Q30. How would you convert this laboratory into a multi-environment Terraform architecture?

I would reuse the modules while separating environment configuration.

For example:

```text
terraform/
├── modules/
│   └── vpc/
│
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

Each environment could define its own:

- CIDR ranges
- subnet ranges
- tags
- workload sizing
- feature configuration

while consuming the same reusable modules where appropriate.

---

## Q31. How would you prevent multiple engineers from modifying Terraform state simultaneously?

I would use a remote state architecture with an appropriate state locking mechanism.

I would also integrate Terraform operations into a controlled CI/CD workflow so production changes are reviewed and serialized appropriately.

---

## Q32. How would you secure Terraform in CI/CD?

I would avoid long-lived static AWS access keys.

A preferred architecture would use short-lived credentials and workload identity/federation, such as GitHub Actions OIDC with an AWS IAM role.

Conceptually:

```text
GitHub Actions
      ↓
OIDC
      ↓
AWS IAM Role
      ↓
Temporary Credentials
      ↓
Terraform
      ↓
AWS
```

I would also implement:

- least-privilege IAM
- protected branches
- pull-request reviews
- Terraform formatting and validation
- plan review
- security scanning
- controlled apply permissions
- protected production environments

---

## Q33. How would you add automated Terraform validation to this repository?

A CI pipeline could execute:

```text
terraform fmt -check
terraform init
terraform validate
terraform plan
```

Additional tools could later perform:

- static analysis
- security scanning
- policy validation

The pipeline would run on pull requests before code is merged.

---

## Q34. What happens if someone deletes a Terraform-managed subnet manually?

Terraform state may still expect that subnet to exist.

During refresh/plan, Terraform can detect that the real resource is missing.

If the configuration still requires it, Terraform will generally propose recreating the missing resource, subject to dependencies and configuration.

This demonstrates Terraform's desired-state model.

---

## Q35. What is one thing you would improve about your current Terraform implementation?

The first major infrastructure-management improvement would be moving local Terraform state to a secure remote backend.

The current local state is acceptable for a controlled learning laboratory, but it is not the model I would choose for collaborative production infrastructure.

---

# 11. Scenario Questions

## Scenario 1

An EC2 instance is launched into one of the private subnets and cannot download operating system packages from the Internet.

### What would you investigate?

I would inspect:

1. subnet route table association
2. private route table routes
3. NAT architecture
4. security groups
5. Network ACLs
6. DNS configuration
7. instance network configuration

In the current lab architecture there is no NAT Gateway, so lack of an outbound Internet route would be expected.

---

## Scenario 2

A developer manually changes a Terraform-managed AWS resource.

### What would you do?

First:

```powershell
terraform plan
```

to inspect the drift.

Then I would determine whether:

- the manual change should be reverted, or
- the Terraform configuration should be updated to represent the approved desired state.

I would avoid applying blindly before understanding the difference.

---

## Scenario 3

Terraform wants to destroy a production resource unexpectedly.

### What would you do?

I would not apply.

I would inspect:

- configuration changes
- Terraform state
- variable values
- module changes
- provider changes
- resource addressing
- recent commits
- plan output

The plan should be understood completely before destructive production changes are approved.

---

## Scenario 4

Two engineers need to work on the same infrastructure.

### What must change from this laboratory?

Local state should be replaced with centralized remote state and appropriate locking.

The team should also use:

```text
Git
Pull Requests
Code Review
CI Validation
Controlled Terraform Apply
```

to manage infrastructure changes safely.

---

# 12. Interview Summary

After completing this laboratory I should be able to explain:

- what Infrastructure as Code is
- how Terraform works
- Terraform provider architecture
- Terraform state
- variables and outputs
- reusable modules
- root vs child modules
- AWS VPC design
- public vs private subnets
- route tables
- Internet Gateways
- multi-AZ networking
- Terraform idempotency
- infrastructure drift
- AWS CLI validation
- Terraform troubleshooting
- Git and Terraform security
- production improvements
- CI/CD integration
- remote state architecture
- secure AWS authentication