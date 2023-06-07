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

<img width="1151" alt="vpc-variable" src="https://github.com/earchibong/eks-2/assets/92983658/ef2aab0c-fd95-4009-ac35-827676b6d0d1">

<br>

<br>


###  create VPC module

This code creates a Virtual Private Cloud (VPC) in AWS using the terraform-aws-modules/vpc/aws module version 3.19.0.

First, it defines a `data resource` of aws_availability_zones with the name "available". This resource allows Terraform to access the list of availability zones in the current AWS region, and it is used to exclude certain availability zones by name.

Next, it creates a module resource of vpc that uses the previously mentioned VPC module. This module resource defines various parameters for the VPC, such as its name, cidr block, and subnet configurations.

The VPC is given a name that is constructed using `local.name` and `var.vpc_name` variables. The CIDR block of the VPC is set using the `var.vpc_cidr_block` variable and the availability zones are determined using the `data.aws_availability_zones.available.names` variable. Public and private subnets are defined using the `var.vpc_public_subnets` and `var.vpc_private_subnets` variables respectively.

A database subnet group is also created, with its configuration determined by the `var.vpc_create_database_subnet_group`, `var.vpc_create_database_subnet_route_table`, and `var.vpc_database_subnets variables`.

The VPC is configured to use NAT gateways for outbound communication by setting `var.vpc_enable_nat_gateway` and `var.vpc_single_nat_gateway` variables to true.

The VPC is also configured with DNS parameters, such as hostname and support, determined by `var.vpc_enable_dns_hostnames` and `var.vpc_enable_dns_support` variables

The tags added to the subnets is very important. The Kubernetes Cloud Controller Manager (cloud-controller-manager) and AWS Load Balancer Controller (aws-load-balancer-controller) needs to identify the cluster’s. To do that, it querries the cluster’s subnets by using the tags as a filter. 

For public and private subnets that use load balancer resources: each subnet must be tagged and for private subnets that use internal load balancer resources: each subnet must be tagged


<br>

- create a file called `vpc-module.tf`


```

# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
  state = "available"
  #exclude_names = ["us-east-1-iah-1a"]
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

<img width="1176" alt="vpc-module" src="https://github.com/earchibong/eks-2/assets/92983658/350395bc-7891-4d8f-bd2d-a4f60e7dafd5">


<br>

<br>

### Create VPC outputs
In Terraform, an outputs file is a configuration file where you define the values that you want to display or retrieve after successfully applying your Terraform configuration. Outputs provide a convenient way to extract information from your infrastructure and make it accessible for further use or for external consumption.

The output values for the Terraform module that creates a VPC will be stored in this `vpc-outputs` file. They include the `ID` and `CIDR` block of the VPC, the IDs of the private and public subnets, the public IPs of the NAT gateways, and the availability zones. These outputs can be used to reference the resources created by the module in other parts of the Terraform configuration.

- create a file called `vpc-outputs.tf`

```

# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}


```

<br>

<br>

<img width="1111" alt="vpc-outputs" src="https://github.com/earchibong/eks-2/assets/92983658/18f649ad-1c9b-433d-9a62-d2a9f4fa5ab1">


<br>

<br>

## Bastion Host Configuration

<br>

### Create EC2 Bastion Variables

The variables that will be created are `instance_type` which specifies the type of EC2 instance to be created and, `instance_keypair` that specifies the key pair that should be associated with the EC2 instance. This key pair is used to enable access to the instance via SSH.

<br>

- create a file named `bastion-variables.tf`

```

# AWS EC2 Instance Terraform Variables

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
}

```

<br>

<br>


<img width="1042" alt="bastion-variables" src="https://github.com/earchibong/eks-2/assets/92983658/82481dfd-3d02-4e75-9d2b-ccc942f7b082">


<br>

<br>

### Create Bastion Security Group
We will name the security group with a specific naming convention, and associate with a VPC that is created by the `vpc module`. The security group here, is allowing incoming traffic on SSH port from any IP address (ingress_cidr_blocks = [“0.0.0.0/0”]) and it allows all outgoing traffic (egress_rules = [“all-all”]) . It also has a specific tag that is being associated with it. This security group can be used when you want to create a bastion host that is publicly accessible via SSH, and you want to allow all outgoing traffic.

- create a file named `bastion-sg-tf`

```

# AWS EC2 Security Group Terraform Module
# Security Group for Public Bastion Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${local.name}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Egress Rule - all-all open
  egress_rules = ["all-all"]

  # SG Tags
  tags = local.common_tags
}

```

<br>

<br>

<img width="1052" alt="bastion-sg" src="https://github.com/earchibong/eks-2/assets/92983658/cd71eeed-9455-4d32-ab88-58dc342c8e8c">


<br>

<br>

### Create DataSource AMI
This will be used to launch an Amazon Linux 2 instance with the latest version of the operating system.

- create a file named `data-source-ami.tf`

```

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

```

<br>

<br>

<img width="1060" alt="data-source-ami" src="https://github.com/earchibong/eks-2/assets/92983658/d997e270-7035-4852-ada5-f1ef0866ea60">


<br>

<br>

### Create Bastion Outputs File

- create a file named `bastion-outputs.tf`

```

# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host

# ec2_bastion_public_instance_ids
output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_bastion.id
}

## ec2_bastion_public_ip
output "ec2_bastion_eip" {
  description = "Elastic IP associated to the Bastion Host"
  value       = aws_eip.bastion_eip.public_ip
}


```

<br>

<br>

<img width="1053" alt="bastion-outputs" src="https://github.com/earchibong/eks-2/assets/92983658/95210df2-451e-4d08-ba2b-29826a9183d8">


<br>

<br>

### Launch Bastion EC2 Instance
This code will use the `ec2-instance` module from the `terraform-aws-modules` library, version 4.3.0. This module creates an EC2 instance within an AWS Virtual Private Cloud (VPC). The specific instance being created is a `Bastion Host`, which is an EC2 instance that will be placed in the VPC’s public subnet.
- create a file named `bastion-ec2-instance`

```

# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name          = "${local.name}-bastion-host"
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  # monitoring             = true
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  # EC2 Bastion Tags
  tags = local.common_tags
}


```

<br>

<br>

<img width="1052" alt="bastion-ec2-instance" src="https://github.com/earchibong/eks-2/assets/92983658/120664ef-a8bb-48c1-aa13-92c7fe57c297">

<br>

<br>


### Create Bastion Elastic IP

- create a file named `ec2-bastion-elastic-ip.tf`

```

# Create Elastic IP for Bastion Host
# Resource - depends_on Meta-Argument
resource "aws_eip" "bastion_eip" {
  depends_on = [
    module.ec2_bastion,
    module.vpc
  ]
  instance = module.ec2_bastion.id
  vpc      = true
}


```

<br>

<br>



<br>

<br>

