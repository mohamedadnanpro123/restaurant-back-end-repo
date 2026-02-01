# 🍽️ Restaurant Solutions — Backend API

Production-grade Node.js backend for the Restaurant Management Platform, deployed on **AWS ECS** with a fully automated CI/CD pipeline.

## 🌐 Live Website
[www.restaurantsolutions.shop](https://www.restaurantsolutions.shop)

---

## 🏗️ Architecture Overview

```
GitHub Actions → Docker Build → ECR → ECS (EC2 Launch Type) → ALB → Users
                                        ↓
                                   RDS MySQL
                                        ↓
                              SSM Parameter Store (Secrets)
```

## ☁️ AWS Services Used

| Category | Services |
|----------|----------|
| **Compute & Containers** | EC2, ECS, ECR, Auto Scaling Groups, Capacity Providers |
| **Networking** | VPC, Subnets, NAT Gateways, ALB, Route 53, ACM SSL |
| **Database** | RDS MySQL, DB Subnet Groups |
| **Storage & CDN** | S3, CloudFront |
| **Security** | IAM Roles, Security Groups, SSM Parameter Store |
| **Monitoring** | CloudWatch Logs |
| **IaC** | Terraform |

---

## 📦 Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MySQL (via RDS)
- **Authentication:** JWT + bcrypt
- **Email:** Gmail SMTP integration
- **Containerization:** Docker
- **IaC:** Terraform

---

## 🔄 CI/CD Pipeline

```
1. Push code to main branch
2. GitHub Actions triggers workflow
3. Docker image built
4. Image pushed to ECR (latest + commit SHA tags)
5. ECS force-new-deployment triggered
6. Rolling update: new containers replace old (zero downtime)
```

### Deployment Strategy
- **Max surge:** 200% (double containers during deploy)
- **Min healthy:** 100% (always 2 containers running)
- **Circuit breaker:** Auto-rollback on failure

---

## 🏢 ECS Configuration

- **Launch Type:** EC2
- **Task CPU:** 256 (0.25 vCPU)
- **Task Memory:** 256 MB
- **Desired Count:** 2 containers minimum
- **Auto Scaling:** Up to 20 containers based on CPU (target: 70%)
- **Capacity Provider:** Managed scaling linked to ASG

---

## 🔐 Security

- All secrets stored in **AWS SSM Parameter Store**
- IAM roles follow **least-privilege** principle:
  - `ecsTaskExecutionRole` — Pull images from ECR, read SSM parameters
  - `ecsTaskRole` — Application-level AWS access
  - `ecsInstanceRole` — EC2 instance registration with ECS cluster
- **IMDSv2** enforced on all EC2 instances
- VPC with **private subnets** for EC2 and RDS
- Security groups restrict traffic between layers

---

## 📁 Project Structure

```
restaurant-back-end-repo/
├── server.js              # Entry point
├── routes/                # API routes
├── middleware/            # Auth middleware (JWT)
├── config/                # Database config
├── Dockerfile             # Container definition
├── .github/
│   └── workflows/
│       └── deploy-production-docker.yml   # CI/CD pipeline
└── terraform/             # Infrastructure as Code
    ├── main.tf
    ├── variables.tf
    ├── compute.tf         # ECS, ASG, Launch Template
    ├── networking.tf      # VPC, Subnets, NAT
    ├── security.tf        # IAM, Security Groups
    └── ecs_userdata.sh    # EC2 user data script
```

---

## 🏥 Health Check

```
GET /api/health
→ 200 OK (monitored by ALB every 30 seconds)
```
