# 📚 Lab 10 — Terraform Study Notes

## 1. What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp.

It allows infrastructure to be defined using declarative configuration files instead of manually creating resources through cloud provider consoles.

The basic workflow is:

```text
Write Configuration
        ↓
terraform init
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
Review Changes
        ↓
terraform apply
        ↓
Infrastructure
```

Terraform configuration files normally use:

```text
.tf
```

and HashiCorp Configuration Language:

```text
HCL
```

---

# 2. Infrastructure as Code

Infrastructure as Code means infrastructure is represented as code.

Instead of manually creating:

```text
VPC
Subnets
Route Tables
Internet Gateway
Security Groups
EC2
RDS
```

the desired infrastructure is declared in configuration files.

Advantages include:

- Reproducibility
- Version control
- Automation
- Consistency
- Reviewable infrastructure changes
- Reduced manual configuration
- Easier disaster recovery
- Reusable infrastructure patterns

---

# 3. Declarative Model

Terraform uses a declarative approach.

We describe the desired final state:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.20.0.0/16"
}
```

We do not explicitly program every AWS API operation necessary to create the VPC.

Terraform determines the required actions.

---

# 4. Terraform Provider

A provider allows Terraform to interact with an external platform.

In this laboratory:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS APIs
    ↓
AWS Infrastructure
```

Example:

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS provider manages communication between Terraform and AWS.

---

# 5. Terraform Initialization

Command:

```powershell
terraform init
```

Purpose:

- Initialize the working directory.
- Download required providers.
- Initialize modules.
- Prepare Terraform backend configuration.
- Create/update the dependency lock file.

In this laboratory Terraform downloaded:

```text
hashicorp/aws
```

and generated:

```text
.terraform.lock.hcl
```

---

# 6. terraform fmt

Command:

```powershell
terraform fmt
```

Purpose:

Automatically formats Terraform configuration according to standard HCL conventions.

For multiple directories:

```powershell
terraform fmt -recursive
```

This improves:

- readability
- consistency
- code review
- maintainability

---

# 7. terraform validate

Command:

```powershell
terraform validate
```

Purpose:

Checks whether the Terraform configuration is syntactically valid and internally consistent.

Successful result:

```text
Success! The configuration is valid.
```

Important:

`terraform validate` does not prove that the infrastructure already exists or that deployment will necessarily succeed.

---

# 8. terraform plan

Command:

```powershell
terraform plan
```

Terraform compares:

```text
Configuration
      +
Terraform State
      +
Current Infrastructure
```

and calculates the required changes.

Possible symbols include:

```text
+ create
~ update
- destroy
-/+ replace
```

In this laboratory the initial plan produced:

```text
Plan: 13 to add, 0 to change, 0 to destroy.
```

This should always be reviewed before deployment.

---

# 9. Saved Terraform Plans

A plan can be saved:

```powershell
terraform plan -out=tfplan
```

and later applied:

```powershell
terraform apply "tfplan"
```

This guarantees that Terraform attempts to apply the reviewed execution plan.

However, once infrastructure state changes, that plan can become stale.

A saved plan should therefore be treated as temporary.

---

# 10. terraform apply

Command:

```powershell
terraform apply
```

Purpose:

Execute the infrastructure changes determined by Terraform.

In this laboratory the initial deployment completed with:

```text
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
```

This created the AWS network architecture defined in code.

---

# 11. Terraform State

Terraform maintains information about managed infrastructure in its state.

Typical local state file:

```text
terraform.tfstate
```

Conceptually:

```text
Terraform Configuration
          ↕
     Terraform State
          ↕
      AWS Resources
```

Terraform uses state to map configuration resources to real cloud resources.

---

# 12. Why Terraform State Matters

Without state, Terraform would have difficulty determining which real AWS resource corresponds to each resource defined in code.

State enables Terraform to determine:

```text
What Terraform manages
What exists
What changed
What must be created
What must be modified
What must be destroyed
```

State should therefore be protected carefully.

---

# 13. Terraform State Security

Terraform state may contain:

- resource identifiers
- infrastructure metadata
- configuration values
- potentially sensitive information

For this reason:

```text
terraform.tfstate
```

should not be committed to a public Git repository.

Our `.gitignore` excludes:

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
tfplan
*.tfvars
```

For production environments, remote state is generally preferable.

Examples include:

```text
Amazon S3
Terraform Cloud / HCP Terraform
```

with appropriate locking, encryption, permissions, and versioning strategies.

---

# 14. terraform state list

Command:

```powershell
terraform state list
```

Displays resources currently managed by Terraform.

In this laboratory it confirmed resources such as:

```text
module.vpc.aws_vpc.main
module.vpc.aws_internet_gateway.main
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_route_table.public
module.vpc.aws_route_table.private
```

This is useful for troubleshooting and state inspection.

---

# 15. Terraform Outputs

Outputs expose useful information from Terraform configuration.

Example:

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

Then:

```powershell
terraform output
```

can display the value.

Outputs are useful for:

- humans
- scripts
- CI/CD pipelines
- other Terraform configurations
- debugging
- deployment automation

---

# 16. Terraform Variables

Variables make infrastructure configurable.

Example:

```hcl
variable "vpc_cidr" {
  type = string
}
```

A value can then be provided through:

```text
terraform.tfvars
```

or other supported Terraform mechanisms.

Variables reduce hardcoded configuration and improve reuse.

---

# 17. Terraform Modules

Modules are reusable groups of Terraform resources.

Our laboratory uses a VPC module:

```text
terraform/
│
├── environments/
│   └── dev/
│
└── modules/
    └── vpc/
```

The environment consumes the reusable module.

Conceptually:

```text
DEV Environment
       ↓
    VPC Module
       ↓
AWS Network Resources
```

This is preferable to duplicating the same resource definitions across environments.

---

# 18. Root Module vs Child Module

The directory where Terraform is executed acts as the root module.

For this laboratory:

```text
terraform/environments/dev
```

is the root module.

The reusable:

```text
terraform/modules/vpc
```

is a child module.

The root module defines the environment.

The child module defines reusable infrastructure logic.

---

# 19. Current Lab Architecture

The Terraform laboratory creates:

```text
AWS Region: us-east-2

VPC
10.20.0.0/16
│
├── Availability Zone us-east-2a
│   ├── Public Subnet
│   │   10.20.1.0/24
│   │
│   └── Private Subnet
│       10.20.11.0/24
│
└── Availability Zone us-east-2b
    ├── Public Subnet
    │   10.20.2.0/24
    │
    └── Private Subnet
        10.20.12.0/24
```

The public subnets use a public route table connected to an Internet Gateway.

---

# 20. Public vs Private Subnets

A subnet is not public merely because of its name.

A public subnet generally has a route allowing Internet-bound traffic through an Internet Gateway.

Example:

```text
0.0.0.0/0
     ↓
Internet Gateway
```

Our public route table contains this route.

The private route table currently does not have that Internet Gateway default route.

---

# 21. Internet Gateway

An Internet Gateway allows communication between a VPC and the Internet when routing and resource configuration permit it.

Architecture:

```text
Internet
   │
Internet Gateway
   │
Public Route Table
   │
Public Subnets
```

Creating an Internet Gateway alone does not automatically make every resource publicly accessible.

Routing, IP addressing, security groups, NACLs, and resource configuration also matter.

---

# 22. Route Tables

Route tables determine where network traffic is directed.

The public route table contains:

```text
10.20.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

The local route enables communication within the VPC CIDR.

The default route sends other IPv4 destinations toward the Internet Gateway.

---

# 23. Multi-AZ Architecture

The laboratory distributes subnets across:

```text
us-east-2a
us-east-2b
```

This introduces a basic multi-Availability-Zone architecture.

Multi-AZ design is important for:

- availability
- resilience
- fault isolation
- production architecture

Future workloads can be distributed across these subnets.

---

# 24. Resource Tags

Resources are tagged with metadata such as:

```text
Environment
ManagedBy
Name
Project
Repository
Tier
```

Example:

```text
ManagedBy = Terraform
Project   = portfolio-terraform
Environment = dev
```

Tags help with:

- resource identification
- cost allocation
- automation
- governance
- operational management

---

# 25. Terraform Idempotency

One of the most important validations performed in this laboratory was:

```powershell
terraform plan
```

after deployment.

Result:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrates the desired-state behavior expected from Infrastructure as Code.

Running Terraform repeatedly against an unchanged configuration should not continuously recreate infrastructure.

---

# 26. Terraform Drift

Drift occurs when real infrastructure differs from the Terraform configuration/state expectations.

Example:

```text
Terraform expects:
Security Group A

Someone manually changes AWS:
Security Group B
```

Terraform can detect differences during:

```powershell
terraform plan
```

This is one reason production infrastructure should minimize uncontrolled manual changes.

---

# 27. Terraform Dependency Graph

Terraform automatically determines dependencies between resources.

Example:

```text
VPC
 ↓
Subnets
 ↓
Route Table Associations
```

Terraform can therefore create independent resources in parallel while respecting required dependencies.

Explicit dependencies can also be expressed when necessary using:

```hcl
depends_on
```

but should not be added unnecessarily when Terraform can infer the dependency.

---

# 28. Terraform and AWS CLI

Terraform and AWS CLI serve different purposes.

```text
Terraform
→ Infrastructure lifecycle management

AWS CLI
→ Direct AWS API interaction and operational validation
```

During this laboratory Terraform deployed the infrastructure while AWS CLI independently validated it.

This combination is useful for Cloud and DevOps engineering.

---

# 29. Authentication Flow Used in the Lab

The local workflow is:

```text
Developer Workstation
        ↓
AWS CLI Authentication
        ↓
AWS Credentials / Session
        ↓
Terraform AWS Provider
        ↓
AWS APIs
        ↓
AWS Infrastructure
```

Before Terraform operations, authentication can be verified with:

```powershell
aws sts get-caller-identity
```

---

# 30. Development Workflow Used

The laboratory follows:

```text
Create / modify .tf files
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
          ↓
terraform output
          ↓
terraform state list
          ↓
AWS CLI validation
          ↓
terraform plan
          ↓
No changes
```

This provides a basic repeatable IaC workflow.

---

# 31. Git Workflow

Terraform source code should be version controlled.

Example workflow:

```text
feature/lab-10-terraform
        ↓
Develop
        ↓
Validate
        ↓
Document
        ↓
Commit
        ↓
Push
        ↓
Pull Request
        ↓
main
```

Generated Terraform state and temporary artifacts must remain outside version control.

---

# 32. Current Limitations

This laboratory is intentionally a foundation.

The current architecture does not yet implement all production capabilities.

Future improvements may include:

- NAT Gateway
- EC2 workloads
- Application Load Balancer
- Auto Scaling
- Security Groups
- VPC endpoints
- Remote Terraform state
- State locking
- CI/CD Terraform validation
- Security scanning
- Multiple environments
- Terraform testing
- IAM roles for automation

These will be addressed progressively in later portfolio work.

---

# 33. Interview Quick Review

## What is Terraform?

An Infrastructure as Code tool used to declaratively provision and manage infrastructure.

## What is Terraform state?

Terraform's mapping between configuration and managed real-world infrastructure.

## What does `terraform plan` do?

Calculates and displays proposed infrastructure changes before they are applied.

## What does `terraform apply` do?

Executes the changes required to reach the desired configuration.

## Why use modules?

To create reusable and maintainable infrastructure components.

## Why shouldn't tfstate be committed?

Because state contains infrastructure metadata and may contain sensitive information.

## What is idempotency?

Repeated execution against an unchanged desired state should result in no infrastructure changes.

## What is drift?

A difference between the expected Terraform-managed configuration and the actual infrastructure.

## Why validate using AWS CLI?

To independently confirm the deployed AWS resources instead of relying only on Terraform state/output.

---

# 34. What This Lab Demonstrates

This laboratory provides practical evidence of:

- Terraform installation and configuration
- AWS provider configuration
- AWS CLI authentication
- Modular Terraform design
- VPC creation using IaC
- Multi-AZ subnet architecture
- Internet Gateway configuration
- Route table configuration
- Terraform variables
- Terraform outputs
- Terraform state management
- Infrastructure tagging
- AWS CLI validation
- Troubleshooting
- Idempotency validation
- Git-based Infrastructure as Code workflow