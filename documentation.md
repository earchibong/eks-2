# Deploying an EKS Cluster with Public and Private Node Groups on AWS With Terraform

<br>

<br>

![image](https://github.com/earchibong/eks-2/assets/92983658/2a3c0ef5-8352-4b11-ae22-0c627581645b)

<br>

<br>

## Project Steps:
- <a href=" ">Environment Setup</a>
- <a href=" ">set up VPC</a>

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

## Set Up VPC

<br>

### Create VPC Variables
A set of input variables in Terraform for creating a virtual private cloud (VPC) in AWS. It includes variables for the VPC name, CIDR block, availability zones, public and private subnets, database subnets, database subnet group, and various settings for NAT gateways, DNS hostnames and support.

- create a file named `vpc-variables.tf`

```

# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
}

# VPC Availability Zones
variable "vpc_availability_zones" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

# VPC Database Subnets
variable "vpc_database_subnets" {
  description = "A list of database subnets inside the VPC"
  type        = list(string)
}

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type        = bool
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type        = bool
}

# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
}

# VPC Enable DNS Hostnames (True or False)
variable "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  type        = bool
}

# VPC Enable DNS Support (True or False)
variable "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  type        = bool
}

```

<br>

<br>

###  create VPC module

```

# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
  #state = "available"
  exclude_names = ["us-east-1-iah-1a"]
}

# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  # VPC Basic Details
  name            = "${local.name}-${var.vpc_name}"
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # Database Subnets
  create_database_subnet_group       = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  database_subnets                   = var.vpc_database_subnets
  #create_database_nat_gateway_route = true
  #create_database_internet_gateway_route = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support

  # VPC Tags
  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type                                              = "Public Subnets"
    "kubernetes.io/role/elb"                          = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Type                                              = "private-subnets"
    "kubernetes.io/role/internal-elb"                 = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }
}


```

<br>

<br>

