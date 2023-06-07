# Deploying an EKS Cluster with Public and Private Node Groups on AWS With Terraform

<br>

<br>

![image](https://github.com/earchibong/eks-2/assets/92983658/2a3c0ef5-8352-4b11-ae22-0c627581645b)

<br>

<br>

## Project Steps:
- <a href=" ">Environment Setup</a>

<br>

<br>


## use your IAM credentials to authenticate the Terraform AWS provider

In AWS Cli set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` variables

<br>

```

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

```

<br>

<br>

## Environment Setup

<br>

### Terraform and Provider Blocks:
The terraform block allows you to set global configuration options for your Terraform project. It is used to configure the behavior and settings of the Terraform tool itself. The provider block is used to define and configure the providers you want to use for your infrastructure resources. Providers are responsible for interacting with various cloud platforms, services

- create a file named `versions.tf`

```

# Terraform Block
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.0"
    }
  }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}
/*
Note-1:  AWS Credentials Profile (profile = "default") configured on your local desktop terminal  
$HOME/.aws/credentials
*/

```

<br>

<br>

<img width="1052" alt="versions" src="https://github.com/earchibong/eks-2/assets/92983658/37f97986-d7f4-487a-a883-a43bf6b42016">


<br>

<br>

### Create Generic Variables
Three input variables are defined, `aws_region`, `environment`, and `business_division`, each with a description and type of `string`. These variables are used to set the region, environment and business division for the AWS resources that will be created by Terraform. These variables can be set in a separate file or passed in when running Terraform, and their values will be used in the Terraform code to configure the AWS resources.

- crearte a file named `generic-variables.tf`

```

# Input Variables

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources are going to be created"
  type        = string
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

# Business Division
variable "business_division" {
  description = "Business Division this Infrastructure belongs"
  type        = string
}

```

<br>

<br>

<img width="1054" alt="generic_variables" src="https://github.com/earchibong/eks-2/assets/92983658/5bd9bd42-4181-4008-a66b-ff6bba588440">


<br>

<br>

### Create Local Variables
Local variables are user-defined variables used to store intermediate values or complex expressions within a configuration file. They are defined within a `locals` block and can be referenced and reused throughout the Terraform configuration.

Local variables are scoped to the module or configuration file in which they are defined. They cannot be accessed outside their defined scope.

Local variables are particularly useful when you need to reuse a value or expression multiple times within your configuration or when you want to improve the readability of your code by abstracting complex calculations or transformations into named variables.

- create a file named `local-vaules.tf`

```

# Define Local Values in Terraform
locals {
  owners           = var.business_division
  environment      = var.environment
  name             = "${var.business_division}-${var.environment}"
  eks_cluster_name = "${local.name}-${var.cluster_name}"

  # Group owners and environment into common_tags
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}

```

<br>

<br>

<img width="1050" alt="local-values" src="https://github.com/earchibong/eks-2/assets/92983658/68bd7fd4-f975-4357-a1bd-bf074b8dc5e0">


<br>

<br>

