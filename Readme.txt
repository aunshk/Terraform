
complete two-tier AWS architecture fully provisioned via Terraform.

---

# Terraform AWS Infrastructure – VPC + EC2 (Public & Private Architecture)

---

# 📌 Project Overview

This Terraform project provisions a complete AWS infrastructure stack including:

### ✅ Networking Layer

* Custom VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* Public Route Table
* Private Route Table
* Route Table Associations

### ✅ Compute Layer

* Public EC2 instance (Bastion Host)
* Private EC2 instance
* Public Security Group
* Private Security Group

### ✅ Remote State Management

* S3 backend
* DynamoDB state locking

---

# 🏗 Architecture Design

```id="arch1"
                          Internet
                              │
                              ▼
                     ┌─────────────────┐
                     │ Internet Gateway│
                     └─────────────────┘
                              │
        ┌─────────────────────────────────────────┐
        │                 VPC                     │
        │            10.0.0.0/16                  │
        │                                         │
        │   ┌─────────────────┐     ┌───────────┐│
        │   │ Public Subnet   │     │ Private   ││
        │   │ 10.0.1.0/24     │     │ Subnet    ││
        │   │                 │     │10.0.2.0/24││
        │   │  Public EC2     │────▶│Private EC2││
        │   │ (Bastion Host)  │ SSH │ No Public ││
        │   └─────────────────┘     │ IP        ││
        │                           └───────────┘│
        └─────────────────────────────────────────┘
```

---

# 📁 Project Structure

```
.
├── backend.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
```

---

# 🔹 Detailed File Explanation

---

# 1️⃣ providers.tf

## Purpose

Defines:

* Required Terraform version
* AWS provider configuration

### Configuration

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### Key Points

* AWS region is dynamically controlled via `terraform.tfvars`
* Ensures provider version consistency

---

# 2️⃣ backend.tf

## Purpose

Configures remote state backend.

```hcl
backend "s3" {
  bucket         = "aunsh-terraform-state-bucket"
  key            = "dev/terraform.tfstate"
  region         = "eu-north-1"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

### Functionality

* Stores Terraform state in S3
* Enables state locking via DynamoDB
* Prevents concurrent state corruption
* Encrypts state at rest

---

# 3️⃣ variables.tf

## Networking Variables

* `vpc_cidr`
* `public_subnet_cidr`
* `private_subnet_cidr`
* `aws_region`

## Compute Variables

* `instance_type`
* `ami_id`
* `key_name`
* `project`

These variables allow the infrastructure to be reused across environments.

---

# 4️⃣ terraform.tfvars

Defines environment-specific values:

```hcl
aws_region            = "eu-north-1"
project               = "terraform-vpc-demo"

vpc_cidr              = "10.0.0.0/16"
public_subnet_cidr    = "10.0.1.0/24"
private_subnet_cidr   = "10.0.2.0/24"

instance_type         = "t3.micro"
ami_id                = "ami-0fa91bc90632c73c9"
key_name              = "awskey"
```

---

# 5️⃣ main.tf – Infrastructure Resources

---

# 🌐 Networking Resources

---

## VPC

```hcl
resource "aws_vpc" "main"
```

* CIDR: 10.0.0.0/16
* DNS hostnames enabled
* DNS support enabled

---

## Public Subnet

```hcl
resource "aws_subnet" "public"
```

* CIDR: 10.0.1.0/24
* Map public IP on launch enabled
* Used for Bastion EC2

---

## Private Subnet

```hcl
resource "aws_subnet" "private"
```

* CIDR: 10.0.2.0/24
* No public IP assignment
* Used for backend/private workloads

---

## Internet Gateway

```hcl
resource "aws_internet_gateway" "igw"
```

* Attached to VPC
* Enables outbound internet access for public subnet

---

## Public Route Table

```hcl
resource "aws_route_table" "public_rt"
```

* Route:

  ```
  0.0.0.0/0 → Internet Gateway
  ```

* Associated with public subnet

---

## Private Route Table

```hcl
resource "aws_route_table" "private_rt"
```

* No internet route
* Associated with private subnet

⚠️ Note: No NAT Gateway configured.
Private instance cannot access internet.

---

# 🔐 Security Groups

---

## Public Security Group

Allows:

* SSH (22) from 0.0.0.0/0
* All outbound traffic

Purpose:

* Bastion host access

---

## Private Security Group

Allows:

* SSH only from Public Security Group
* All outbound traffic

This enforces:

✔ No direct internet access
✔ Only bastion-to-private communication

---

# 🖥 EC2 Instances

---

## Public EC2 (Bastion)

* Deployed in public subnet
* Public IP enabled
* Attached to public security group
* 8GB gp3 root volume
* SSH key configurable

Tag:

```
${var.project}-public-ec2
```

---

## Private EC2

* Deployed in private subnet
* No public IP
* Attached to private security group
* 8GB gp3 root volume

Tag:

```
${var.project}-private-ec2
```

---

# 6️⃣ outputs.tf

Outputs include:

* VPC ID
* Public Subnet ID
* Private Subnet ID
* Public EC2 ID
* Private EC2 ID
* Public EC2 Public IP
* Private EC2 Private IP

These outputs help:

* Verification
* SSH connectivity
* Integration with other modules

---

# 🔄 Resource Dependency Flow

1. VPC created
2. Subnets created
3. Internet Gateway attached
4. Route tables configured
5. Security groups created
6. EC2 instances deployed

Terraform automatically manages resource dependency graph.

---

# 🚀 Deployment Steps

## Step 1 – Initialize

```bash
terraform init
```

## Step 2 – Validate

```bash
terraform validate
```

## Step 3 – Plan

```bash
terraform plan
```

## Step 4 – Apply

```bash
terraform apply
```

---

# 🔐 Security Considerations

| Area        | Current State  | Recommendation                         |
| ----------- | -------------- | -------------------------------------- |
| SSH Access  | Open to world  | Restrict to your IP                    |
| NAT Gateway | Not configured | Add for private subnet internet access |
| IAM Role    | Not attached   | Attach least privilege IAM role        |
| NACL        | Default        | Customize for tighter control          |

---

# 📊 Infrastructure Summary

| Resource         | Count |
| ---------------- | ----- |
| VPC              | 1     |
| Subnets          | 2     |
| Internet Gateway | 1     |
| Route Tables     | 2     |
| Security Groups  | 2     |
| EC2 Instances    | 2     |
| S3 Backend       | 1     |
| DynamoDB Table   | 1     |

---

# 🎯 Use Cases

This infrastructure is suitable for:

* Dev/Test environments
* Learning Terraform networking
* Bastion architecture demonstration
* Interview demonstration project
* Foundation for multi-tier architecture

---

# 🏁 Conclusion

This Terraform project now provisions:

✔ Complete VPC networking
✔ Public & Private subnet isolation
✔ Bastion architecture
✔ Remote backend best practices
✔ Parameterized infrastructure

It demonstrates:

* Infrastructure as Code best practices
* Secure network segmentation
* Remote state management
* Proper resource dependency handling

---
