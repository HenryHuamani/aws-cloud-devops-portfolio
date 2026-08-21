# 🧰 Lab 10 — Terraform Commands

This document contains the main Terraform and AWS CLI commands used during the implementation and validation of the AWS Infrastructure as Code laboratory.

---

# 1. Local Tool Validation

## Terraform Version

```powershell
terraform --version
```

Validated environment:

```text
Terraform v1.15.9
on windows_amd64
```

---

## AWS CLI Version

```powershell
aws --version
```

---

# 2. AWS CLI Authentication

The AWS CLI was authenticated using:

```powershell
aws login
```

The default AWS Region configured for this laboratory was:

```text
us-east-2
```

Verify the configured region:

```powershell
aws configure get region
```

---

## Verify AWS Identity

```powershell
aws sts get-caller-identity
```

This command validates that the AWS CLI session is authenticated before Terraform communicates with AWS APIs.

> Never store AWS credentials, access keys, tokens, or MFA codes in the repository.

---

# 3. Existing AWS Infrastructure Review

Before deploying Terraform-managed resources, existing resources in the AWS account were reviewed to avoid modifying or duplicating previous laboratory infrastructure.

## Existing VPCs

```powershell
aws ec2 describe-vpcs `
  --region us-east-2 `
  --query "Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,Default:IsDefault}" `
  --output table
```

---

## Existing EC2 Instances

```powershell
aws ec2 describe-instances `
  --region us-east-2 `
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType}" `
  --output table
```

---

## Existing RDS Instances

```powershell
aws rds describe-db-instances `
  --region us-east-2 `
  --query "DBInstances[].{DB:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Class:DBInstanceClass}" `
  --output table
```

---

# 4. Terraform Working Directory

Terraform commands for this environment are executed from:

```text
labs/10-TERRAFORM/terraform/environments/dev
```

Navigate to the environment:

```powershell
cd .\labs\10-TERRAFORM\terraform\environments\dev
```

---

# 5. Terraform Initialization

Initialize the working directory:

```powershell
terraform init
```

This command:

- initializes the Terraform working directory,
- downloads required providers,
- initializes modules,
- creates or updates `.terraform.lock.hcl`.

---

# 6. Terraform Formatting

Format Terraform configuration:

```powershell
terraform fmt
```

Format the configuration recursively:

```powershell
terraform fmt -recursive
```

---

# 7. Terraform Validation

Validate the Terraform configuration:

```powershell
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

# 8. Terraform Plan

Review proposed infrastructure changes:

```powershell
terraform plan
```

Initial deployment plan:

```text
Plan: 13 to add, 0 to change, 0 to destroy.
```

This step must be reviewed before applying infrastructure changes.

---

# 9. Save Terraform Plan

Create a saved execution plan:

```powershell
terraform plan -out=tfplan
```

Inspect a saved plan:

```powershell
terraform show tfplan
```

---

# 10. Terraform Apply

Apply the previously reviewed plan:

```powershell
terraform apply "tfplan"
```

Initial deployment result:

```text
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
```

---

# 11. Terraform Outputs

Display infrastructure outputs:

```powershell
terraform output
```

Outputs configured in this laboratory include:

```text
internet_gateway_id
private_route_table_id
private_subnet_ids
public_route_table_id
public_subnet_ids
vpc_id
```

---

# 12. Terraform State

List resources currently managed by Terraform:

```powershell
terraform state list
```

The state contains the VPC networking resources created by the reusable VPC module.

---

# 13. Idempotency Validation

Run Terraform plan again after deployment:

```powershell
terraform plan
```

Expected result when infrastructure matches the desired configuration:

```text
No changes. Your infrastructure matches the configuration.
```

This validates Terraform idempotency and confirms that the deployed infrastructure is synchronized with the Terraform configuration.

---

# 14. AWS CLI — VPC Validation

Validate the Terraform-managed VPC:

```powershell
aws ec2 describe-vpcs `
  --region us-east-2 `
  --filters "Name=tag:Project,Values=portfolio-terraform" `
  --query "Vpcs[].{Name:Tags[?Key=='Name']|[0].Value,VpcId:VpcId,CIDR:CidrBlock,State:State}" `
  --output table
```

Expected CIDR:

```text
10.20.0.0/16
```

Expected state:

```text
available
```

---

# 15. AWS CLI — Subnet Validation

Validate the deployed public and private subnets:

```powershell
aws ec2 describe-subnets `
  --region us-east-2 `
  --filters "Name=tag:Project,Values=portfolio-terraform" `
  --query "Subnets[].{Name:Tags[?Key=='Name']|[0].Value,SubnetId:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,PublicIP:MapPublicIpOnLaunch}" `
  --output table
```

Validated network layout:

```text
us-east-2a
├── Public  10.20.1.0/24
└── Private 10.20.11.0/24

us-east-2b
├── Public  10.20.2.0/24
└── Private 10.20.12.0/24
```

---

# 16. AWS CLI — Route Table Validation

Validate Terraform-managed route tables:

```powershell
aws ec2 describe-route-tables `
  --region us-east-2 `
  --filters "Name=tag:Project,Values=portfolio-terraform" `
  --query "RouteTables[].{Name:Tags[?Key=='Name']|[0].Value,RouteTableId:RouteTableId,VpcId:VpcId}" `
  --output table
```

---

# 17. AWS CLI — Public Internet Route

Validate the public route table:

```powershell
aws ec2 describe-route-tables `
  --region us-east-2 `
  --route-table-ids <PUBLIC_ROUTE_TABLE_ID> `
  --query "RouteTables[].Routes[].{Destination:DestinationCidrBlock,Gateway:GatewayId,State:State}" `
  --output table
```

Expected routes:

```text
10.20.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

---

# 18. AWS CLI — Public Subnet Associations

Validate public subnet associations:

```powershell
aws ec2 describe-route-tables `
  --region us-east-2 `
  --route-table-ids <PUBLIC_ROUTE_TABLE_ID> `
  --query "RouteTables[].Associations[].{SubnetId:SubnetId,AssociationId:RouteTableAssociationId,Main:Main}" `
  --output table
```

---

# 19. AWS CLI — Private Subnet Associations

Validate private subnet associations:

```powershell
aws ec2 describe-route-tables `
  --region us-east-2 `
  --route-table-ids <PRIVATE_ROUTE_TABLE_ID> `
  --query "RouteTables[].Associations[].{SubnetId:SubnetId,AssociationId:RouteTableAssociationId,Main:Main}" `
  --output table
```

---

# 20. Git Validation

Review repository state before committing:

```powershell
git status
```

Show ignored Terraform files:

```powershell
git status --ignored
```

Show all untracked files:

```powershell
git status --untracked-files=all
```

---

# 21. Terraform Files Excluded from Git

The repository intentionally ignores:

```text
.terraform/
*.tfstate
*.tfstate.*
tfplan
*.tfvars
```

Terraform state and execution plans must not be committed to the repository.

---

# 22. Useful Terraform Commands

## Show Current State

```powershell
terraform show
```

---

## Show Providers

```powershell
terraform providers
```

---

## Inspect Output as JSON

```powershell
terraform output -json
```

---

## Reinitialize After Module or Backend Changes

```powershell
terraform init -reconfigure
```

---

# Important Safety Rule

Before executing:

```powershell
terraform apply
```

always review:

```powershell
terraform plan
```

and verify that the summary does not contain unexpected changes or resource destruction.

Example:

```text
Plan: X to add, 0 to change, 0 to destroy.
```

Avoid applying infrastructure changes if Terraform proposes unexpected destruction until the cause has been reviewed.