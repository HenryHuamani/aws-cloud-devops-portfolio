# 🔧 Lab 10 — Terraform Troubleshooting

This document records real issues encountered during the implementation of the Terraform AWS infrastructure laboratory, including root cause analysis and resolution.

The purpose is to demonstrate practical troubleshooting skills when working with Terraform, AWS CLI, authentication, local development environments, and Infrastructure as Code workflows.

---

# 1. Terraform Command Not Recognized

## Problem

When Terraform was initially executed from PowerShell:

```powershell
terraform --version
```

PowerShell returned:

```text
terraform : The term 'terraform' is not recognized as the name of a cmdlet,
function, script file, or operable program.
```

## Root Cause

Terraform had been downloaded as a Windows binary, but the directory containing `terraform.exe` was not available through the Windows `PATH` environment variable.

Terraform does not use a traditional Windows installer when downloaded as a binary.

## Resolution

The AMD64 Terraform binary was downloaded because the workstation architecture was confirmed using:

```powershell
$env:PROCESSOR_ARCHITECTURE
```

Result:

```text
AMD64
```

The directory containing `terraform.exe` was then added to the Windows `PATH`.

After restarting the terminal:

```powershell
terraform --version
```

returned:

```text
Terraform v1.15.9
on windows_amd64
```

## Lesson Learned

Installing a CLI tool and making the executable available through `PATH` are separate steps.

When a command is not recognized, verify:

1. The executable exists.
2. The correct architecture was downloaded.
3. Its directory is included in `PATH`.
4. The terminal was restarted after changing environment variables.

---

# 2. AWS CLI Credentials Not Available

## Problem

The following command was executed:

```powershell
aws sts get-caller-identity
```

AWS CLI returned:

```text
Unable to locate credentials.
```

## Root Cause

AWS CLI was installed correctly, but no authenticated AWS session was available.

Terraform requires valid AWS credentials because the AWS provider communicates with AWS APIs during planning and deployment.

## Resolution

Authentication was initiated using:

```powershell
aws login
```

The AWS Region was configured as:

```text
us-east-2
```

Authentication was then validated with:

```powershell
aws sts get-caller-identity
```

and the configured Region was checked using:

```powershell
aws configure get region
```

## Lesson Learned

Tool installation does not imply cloud authentication.

Before executing Terraform against AWS, validate the AWS CLI session.

A useful pre-flight check is:

```powershell
aws sts get-caller-identity
aws configure get region
```

---

# 3. AWS Login Session Expired During Terraform Plan

## Problem

Terraform initialization and validation succeeded:

```powershell
terraform init
terraform validate
```

but:

```powershell
terraform plan
```

failed with:

```text
Error: No valid credential sources found
```

and:

```text
failed to refresh cached credentials,
login session has expired,
please reauthenticate
```

## Root Cause

The AWS CLI authentication session had expired.

`terraform init` does not necessarily require active AWS API access for every operation, while `terraform plan` using the AWS provider needs valid credentials to inspect AWS resources.

## Resolution

AWS authentication was renewed:

```powershell
aws login
```

The session was validated:

```powershell
aws sts get-caller-identity
```

Then:

```powershell
terraform plan
```

was executed again successfully.

## Lesson Learned

Authentication should be validated before Terraform operations that interact with AWS APIs.

A successful `terraform init` or `terraform validate` does not guarantee that AWS credentials are currently valid.

---

# 4. Terraform Executed from the Wrong Directory

## Problem

During the laboratory, Terraform commands were accidentally executed from the repository root:

```text
aws-cloud-devops-portfolio/
```

Running:

```powershell
terraform init
```

returned:

```text
Terraform initialized in an empty directory!
```

## Root Cause

The current PowerShell working directory did not contain Terraform `.tf` configuration files.

The actual environment configuration was located in:

```text
labs/10-TERRAFORM/terraform/environments/dev
```

## Resolution

The correct working directory was selected:

```powershell
cd D:\Arquitectura\aws-cloud-devops-portfolio\labs\10-TERRAFORM\terraform\environments\dev
```

Then the workflow was repeated:

```powershell
terraform fmt -recursive
terraform init
terraform validate
```

Terraform correctly detected the VPC module and AWS provider configuration.

## Lesson Learned

Always verify the current working directory before running Terraform.

Useful PowerShell command:

```powershell
Get-Location
```

Terraform commands should normally be executed from the directory representing the intended root module/environment.

---

# 5. PowerShell Interpreted Terraform Command as Part of `cd`

## Problem

A navigation command and Terraform command were entered together incorrectly:

```powershell
cd .\labs\10-TERRAFORM\terraform\environments\dev\terraform fmt -recursive
```

PowerShell attempted to interpret the entire expression as arguments to `Set-Location`.

## Root Cause

`cd` and `terraform fmt` are separate commands.

PowerShell therefore interpreted `terraform`, `fmt`, and the remaining arguments as part of the directory navigation command.

## Resolution

Commands were executed separately:

```powershell
cd .\labs\10-TERRAFORM\terraform\environments\dev
terraform fmt -recursive
```

Alternatively:

```powershell
cd .\labs\10-TERRAFORM\terraform\environments\dev; terraform fmt -recursive
```

## Lesson Learned

When troubleshooting CLI commands, separate navigation from execution.

This also makes command history easier to understand and reproduce.

---

# 6. Terraform Output Returned "No Outputs Found"

## Problem

After the first infrastructure deployment:

```powershell
terraform output
```

returned:

```text
Warning: No outputs found
```

The infrastructure itself had already been successfully created.

## Root Cause

Resources existed in Terraform state, but the root Terraform configuration did not expose module values using Terraform `output` blocks.

Terraform module outputs do not automatically become outputs of the root module.

## Resolution

Root outputs were defined in:

```text
terraform/environments/dev/outputs.tf
```

The configuration exposed values such as:

```text
vpc_id
public_subnet_ids
private_subnet_ids
internet_gateway_id
public_route_table_id
private_route_table_id
```

After formatting and validation:

```powershell
terraform fmt
terraform validate
terraform plan
terraform apply
```

the outputs became available:

```powershell
terraform output
```

## Lesson Learned

Terraform outputs must be explicitly exposed by the root module.

Reusable modules and root environment configuration have different responsibilities.

---

# 7. Saved Terraform Plan Became Stale

## Problem

After successfully applying:

```powershell
terraform apply "tfplan"
```

the same saved plan was executed again:

```powershell
terraform apply "tfplan"
```

Terraform returned:

```text
Error: Saved plan is stale
```

## Root Cause

A saved Terraform plan represents a specific infrastructure state at the moment the plan was generated.

The first `terraform apply` changed Terraform state.

Therefore, the previously saved `tfplan` no longer represented the current state and Terraform correctly refused to reuse it.

## Resolution

A new plan can be generated:

```powershell
terraform plan -out=tfplan
```

or the current infrastructure can simply be checked with:

```powershell
terraform plan
```

The final validation returned:

```text
No changes. Your infrastructure matches the configuration.
```

## Lesson Learned

Terraform plan files are not reusable indefinitely.

A saved plan should normally follow this lifecycle:

```text
terraform plan -out=tfplan
        ↓
review
        ↓
terraform apply tfplan
        ↓
discard plan
```

After state changes, generate a new plan.

---

# 8. Terraform State Files Appearing Locally

## Problem

Terraform generated local files including:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
tfplan
```

These files should not be committed to a public Git repository.

## Risk

Terraform state can contain infrastructure metadata and potentially sensitive values.

The `.terraform` directory also contains downloaded providers and local working data.

Saved execution plans are generated artifacts rather than source configuration.

## Resolution

The repository `.gitignore` was configured to exclude:

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
tfplan
*.tfvars
```

Verification was performed using:

```powershell
git status --ignored
```

and:

```powershell
git status --untracked-files=all
```

The Terraform source configuration remained visible to Git while generated state and working files were ignored.

## Lesson Learned

Infrastructure as Code repositories should version the configuration, not local Terraform runtime artifacts.

Before committing Terraform projects, always inspect:

```powershell
git status
git status --ignored
```

---

# 9. AWS Infrastructure Validation

Terraform reported successful deployment, but infrastructure was also validated independently using AWS CLI.

This provided a second source of verification beyond Terraform state.

## VPC

Validated:

```text
CIDR: 10.20.0.0/16
State: available
```

## Subnets

Validated across two Availability Zones:

```text
us-east-2a
├── Public  10.20.1.0/24
└── Private 10.20.11.0/24

us-east-2b
├── Public  10.20.2.0/24
└── Private 10.20.12.0/24
```

## Routing

The public route table contained:

```text
10.20.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

Public and private subnet associations were also validated independently.

## Lesson Learned

A successful Terraform apply is important, but infrastructure validation should not rely exclusively on Terraform output.

AWS CLI can independently confirm that the desired architecture exists in the cloud provider.

---

# 10. Troubleshooting Workflow

The general troubleshooting workflow established during this laboratory is:

```text
Problem detected
      ↓
Verify current directory
      ↓
Verify local tools
      ↓
Verify AWS authentication
      ↓
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review proposed changes
      ↓
terraform apply
      ↓
terraform output
      ↓
terraform state list
      ↓
AWS CLI independent validation
      ↓
terraform plan
      ↓
Confirm idempotency
```

---

# Key Engineering Takeaways

This laboratory demonstrated several operational principles relevant to Cloud and DevOps engineering:

- Validate tooling before infrastructure deployment.
- Validate cloud authentication independently.
- Understand Terraform root modules and reusable modules.
- Never blindly execute `terraform apply`.
- Treat Terraform state as sensitive operational data.
- Do not reuse stale execution plans.
- Validate deployed infrastructure independently using cloud APIs.
- Verify idempotency after deployment.
- Keep troubleshooting documentation as part of the Infrastructure as Code repository.