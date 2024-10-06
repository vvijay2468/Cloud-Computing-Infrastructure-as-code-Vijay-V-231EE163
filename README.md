# Web Enthusiast Club Recruitment Task

[![LinkedIn](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/vijay-v-0889a1280/)

## Introduction

Hello and welcome to my repository! 👋

This repo is part of my submission for the Web Enthusiast Club (WEC) recruitment task in **Cloud Computing and Infrastructure as Code (IaC)**. Below, you'll find details on how I approached and solved the task, including:

- A step-by-step explanation of the implementation.
- Documentation and resources I referred to during the task.
- Screenshots and a video demonstration showcasing the final working architecture.

Feel free to explore the repo and check out the documentation to get a complete understanding of the architecture and the deployment process. 😊
## 🚀 About Me

I am Vijay V (231EE163) 👋

I am passionate about **systems**, especially **cloud** and **networking**. I'm always eager to learn more from like-minded individuals and explore new technologies in these fields.
## Deployment

To deploy this project, follow these steps:

1. Navigate to the directory where your `.tf` (Terraform) files are located.

2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

- `terraform init`: This command initializes your working directory with the necessary plugins and providers specified in your configuration files. It downloads the required provider binaries.

- `terraform plan`: It creates an execution plan, showing what changes Terraform will apply to achieve the desired infrastructure state. This step allows you to verify the changes before applying them.

- `terraform apply`: This command executes the actions proposed in the `terraform plan`, creating or modifying resources in your infrastructure based on the `.tf` files.


## Environment Variables

To run this project, you will need to add the following variables to your variable.tf file.

```
variable "subscription_id" {
   description = "Azure subscription"
   default = "XXXXX-XXXXXXX-XXXXXXXX-XXXXXXX"
}


variable "tenant_id" {
   description = "Azure Tenant ID"
   default = "XXXXXX-XXXXXXX-XXXXXXX-XXXXXXX"
}

variable "instance_size" {
   type = string
   description = "Azure instance size"
   default = "Standard_F2"
}

variable "location" {
   type = string
   description = "Region"
   default = "West US"
}

variable "environment" {
   type = string
   description = "Environment"
   default = "dev"
}


```