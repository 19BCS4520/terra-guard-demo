# 🛡️ Terra-Guard Protocol: Resilient Infrastructure Lab

![Terraform Version](https://img.shields.io/badge/Terraform-v1.6+-purple?style=for-the-badge&logo=terraform)
![AWS Provider](https://img.shields.io/badge/AWS-Provider-orange?style=for-the-badge&logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

> **A production-grade Terraform simulation demonstrating advanced lifecycle management, disaster recovery patterns, and immutable infrastructure concepts.**

---

## 📖 Project Overview

**Terra-Guard** is a "Microservices Base Layer" simulation designed to showcase **Self-Healing Infrastructure**. Unlike standard "Hello World" demos, this project focuses on the *day-2 operations* of DevOps: handling dependencies, preventing accidental deletions, and managing multi-region compliance.

### 🎯 Key Concepts Demoed

| Concept | Feature Used | Real-World Application |
| :--- | :--- | :--- |
| **Numeric Scaling** | `count` | Rapidly provisioning identical web server fleets. |
| **Logical Scaling** | `for_each` | Managing distinct team resources (buckets, users) via maps. |
| **Disaster Recovery** | `provider` (alias) | Replicating critical logs to a secondary region (`us-west-1`). |
| **Zero-Downtime** | `create_before_destroy` | Updating Firewalls/SGs without cutting off active traffic. |
| **Safety Belts** | `prevent_destroy` | Protecting production databases from accidental CLI deletion. |
| **Immutability** | `replace_triggered_by` | Forcing server replacement when configuration files change. |
| **Race Conditions** | `depends_on` | Solving hidden S3-upload vs. EC2-boot timing issues. |

---

## 🏗️ Architecture Flow

This diagram illustrates how Terraform processes the configuration logic before touching AWS APIs.

```mermaid
graph TD
    %% Definitions and Styling
    classDef config fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#01579b;
    classDef plan fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,color:#333;
    classDef act fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#333;
    classDef aws fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#333;
    classDef check fill:#ffebee,stroke:#c62828,stroke-width:2px,stroke-dasharray: 5 5,color:#c62828;

    %% Main Flow
    subgraph "1. CONFIGURATION STAGE"
        TF[".tf Files"]:::config --> Locals[Calculate Locals]:::config
    end

    subgraph "2. PLANNING ENGINE"
        Direction("Terraform Core"):::plan
        PreCond{"LIFECYCLE Check:
        precondition"}:::check
        PreCond -- "Pass" --> Scaling("Expand count/for_each"):::plan
        Scaling --> Routing("PROVIDER Routing"):::plan
    end

    subgraph "3. EXECUTION STAGE"
        Lifecycle("Lifecycle Hooks:
        create_before_destroy
        ignore_changes"):::act
        Lifecycle ==> AWS_API(AWS APIs):::aws
    end

    Locals --> Direction
    Direction --> PreCond
    Routing --> Lifecycle
