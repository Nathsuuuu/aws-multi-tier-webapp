<h1> AWS Multi-Tier Web App Deployment 🚀  </h1><br>
This project showcases the deployment of a scalable and secure three-tier web architecture on Amazon Web Services (AWS) using Terraform for Infrastructure as Code (IaC).  
It demonstrates how to separate the presentation, application, and database layers into distinct tiers — improving scalability, reliability, and maintainability.

---

 🚀 Key Features
- Infrastructure as Code: Entire environment provisioned automatically with Terraform  
- Multi-Tier Architecture: Separate web (EC2), application (Load Balancer), and database (RDS) layers  
- Scalability: Easily adjustable instance types and database configurations  
- Security: Private subnets for RDS, public subnet for EC2, and strict security groups  
- Automation: Web server auto-configured using user data (Bash script)  
- Cost-Effective Design: Uses free-tier eligible AWS services and minimal configuration  

---

 🧰 Tech Stack
- AWS Services: EC2, RDS (MySQL), VPC, Security Groups, Load Balancer  
- Terraform: Infrastructure provisioning and configuration management  
- Linux (Ubuntu): Web server environment  
- Bash: Used for automatic Apache setup  
- Git & GitHub: Version control and project documentation  

---

 🏗️ Architecture Overview
1. VPC with one public subnet (for EC2) and one private subnet (for RDS)  
2. Internet Gateway attached for external access  
3. EC2 Instance (Web Tier) running Apache web server  
4. Elastic Load Balancer (App Tier) managing inbound traffic  
5. RDS MySQL Database (Data Tier) for persistent storage  
6. Security Groups enforcing network segmentation  

---

 ⚙️ Deployment Steps
```bash
terraform init
terraform plan
terraform apply -auto-approve
