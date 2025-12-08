# DevSecOps Terraform AWS Demo Pipeline
This repository contains a **GitHub Actions pipeline** that demonstrates a simple **DevSecOps workflow for Terraform on AWS**.

The goal is to show how to combine:

- ✅ Terraform formatting, init, validate  
- ✅ Static analysis for Terraform (**TFLint**)  
- ✅ IaC security scanning (**Checkov**)  
- ✅ Terraform plan gated by security checks  

---

## 🧱 Pipeline Overview

The workflow file is: `.github/workflows/devsecops-terraform-aws.yml` (or similar).

It runs on:

- `push` to the `main` branch  
- manual trigger via **`workflow_dispatch`**

The pipeline is composed of the following jobs:

1. **`terraform` – Terraform Init & Format**
   - Checks out the repository  
   - Sets up Terraform  
   - Runs `terraform fmt`  
   - Runs `terraform init`  

2. **`terraform-validate` – Terraform Validation**
   - Depends on `terraform`  
   - Checks out the code  
   - Sets up Terraform  
   - Runs `terraform init`  
   - Runs `terraform validate -no-color`  

3. **`tflint` – Terraform Linting**
   - Depends on `terraform-validate`  
   - Uses **TFLint** to lint Terraform code  
   - Caches TFLint plugins for faster runs  
   - Runs `tflint -f compact`  

4. **`checkov` – IaC Security Scanning**
   - Depends on `tflint`  
   - Uses **Checkov** to scan Terraform for misconfigurations and security issues  
   - Generates **SARIF** output (`results.sarif`)  
   - Uploads the SARIF file to **GitHub Code Scanning** (`Security > Code scanning alerts`)  

5. **`plan` – Terraform Plan**
   - Depends on `checkov`  
   - Runs only after security scanning  
   - Executes:
     - `terraform init`  
     - `terraform plan -out=tfplan -no-color`  

This models a simple **Security Gate**:  
➡️ Only after formatting, validation, linting and security scanning, the pipeline generates a Terraform plan.

---

## 🔐 AWS Configuration (Secrets)

The workflow expects the following **GitHub Secrets** to be configured in the repository:

- `AWS_ACCESS_KEY` – IAM Access Key ID  
- `AWS_SECRET_KEY` – IAM Secret Access Key  

These are exposed to the workflow as:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_KEY }}
  AWS_DEFAULT_REGION: sa-east-1
