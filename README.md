# XCT TAKE HOME CHALLENGE

# Overview
This repo can be used to deploy an EKS cluster running two httpbin endpoints, one internal and one external

## PREREQUISITES
The following utilities are used to deploy this project (versions tested in brackets)
aws cli (2.17.18)
terraform (1.10.5)
helm (3.17.1)
helmfile(0.171.0)

The solution must be deployed to an AWS region with at least three availability zones. It has been tested in eu-west-1

The following AWS resources are needed:
1. IAM role with sufficient permissions to create/upgrade/delete resources
2. A route53 public hosted zone
3. An EC2 key pair
5. An IAM role for root access to the EKS cluster, the "devops" role

## DEPLOYMENT INSTRUCTIONS
1. [Install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [Install helm](https://helm.sh/docs/intro/install/)
3. [Install helmfile](https://helmfile.readthedocs.io/en/latest/#installation)

### DEPLOY NETWORK MODULE
1. cd terraform_modules/xct_network
2. Run `terraform init && terraform apply -var 'environment=dev'`


### DEPLOY EKS MODULE
1. cd terraform_modules/xct_eks
2. Run `terraform init && terraform apply -var 'environment=dev' \n
                            -var 'route53_zone_id=ROUTE53_ZONE_ID' \n
                            -var 'key_name=EC2_KEY_PAIR \n
                            -var 'admin_role_arn=ADMIN_ROLE_ARN \n`

### DEPLOY HELM CHARTS USING HELMFILE
1. cd helmfile
2. Run `export AWS_REGION=eu-west-1` (change region as needed)
3. Run `helmfile sync`

## SOLUTION OVERVIEW

## NETWORK CONFIGURATION
This solution deploys a single VPC (/16 network). The VPC consists of nine subnets of the following configuration:

* 3 Public Subnets
* 3 Private Subnets
* 3 Data Subnets

Public subnets contain all resources that require direct public internet connectivity. In this solution, only the external load balancer and the NAT gateway sit here

Private subnets contain all resources that do not require public IP addresses, such as the EKS cluster and the internal load balancer.

Data subnets are unused in this solution, but are added to demonstrate best practice. Data subnets are reserved for persistent data (e.g. databases/RDS instances). Data subnets have an extra layer of security as there is an explicit DENY on the postgres TCP port for sources outside the VPC. This protects against future VPC peering from inadvertantly getting access to data.

## INGRESS
Ingress to the EKS cluster is via the AWS Load Balancer Controller using [Target Group Binding](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/targetgroupbinding/targetgroupbinding/) only. This allows for multiple deployments on the cluster to use the same load balancer (reduces cost)

### MODULES

* helm_charts - contains the source code of a helm chart that deploys a TargetGroupBinding resource, this binds the AWS Load balanacer controller to the target group

* terraform_modules - contains terraform modules to deploy the AWS infrastructure. It contains two modules: xct_network (deploys VPC related resources) and xct_eks (deploys EKS related resources)

* helmfile - contains a helmfile resource which is used to deploy the helm charts

