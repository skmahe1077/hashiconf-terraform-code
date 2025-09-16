# HashiConf Demo: Terraform Code for Sentinel Policies
This repository contains Terraform configuration that will be used in Sentinel demos at HashiConf.
The Terraform resources here are intentionally simple and include both compliant and non-compliant configurations so Sentinel policies can be demonstrated effectively

### **Repo Structure**
```plaintext
hashiconf-terraform-code/
├─ main.tf         # Terraform AWS resources (some compliant, some non-compliant)
├─ variables.tf    # Region and variables
├─ providers.tf    # AWS + random providers
├─ backend.tf      # (optional) S3 backend for remote state
└─ README.md       # This file
```

### **Resource Compliance States**
  - **EBS volumes must be encrypted**:
    ❌ Non-compliant: EBS volume created without encryption
  - **Security Groups must not allow 0.0.0.0/0 on port 22**:
    ❌ Non-compliant: SSH (22) open to the world
  - **Block S3 public access at the bucket level**:
    ❌ Non-compliant: Bucket ACL or policy allows public access
  - **Require MFA delete for S3 buckets**:
    ❌ Non-compliant: Bucket created without MFA delete
  - **Block S3 public access at the account level**:
    ✅ Compliant: Account-level Public Access Block configured
