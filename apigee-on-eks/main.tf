# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.eks_region
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "hybrid-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "hybrid-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "apigee-runtime"

      instance_types = ["t3.xlarge"]

      min_size     = 2
      max_size     = 2
      desired_size = 2
      tags = {
        "cloud.google.com/gke-nodepool" = "apigee-runtime" 
      }
      labels = {
        "nodepool-purpose"            = "apigee-runtime"
        "cloud.google.com/gke-nodepool" = "apigee-runtime"
      }
    }

    two = {
      name = "apigee-data"

      instance_types = ["t3.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
      tags = {
        "cloud.google.com/gke-nodepool" = "apigee-data"
      }
      labels = {
        "nodepool-purpose"            = "apigee-runtime"
        "cloud.google.com/gke-nodepool" = "apigee-runtime"
      }
    }
  }

  depends_on = [module.vpc]
}

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${local.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  depends_on = [module.eks]
}

# Add EBS CSI driver addon after IRSA role is created
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name              = "aws-ebs-csi-driver"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn

  depends_on = [module.irsa-ebs-csi]
}

resource "null_resource" "cluster_setup" {
  # Use local-exec provisioner to run a script to configure kubectl
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.cluster_name} --region ${var.eks_region}"
  }

  depends_on = [module.eks, aws_eks_addon.ebs_csi]
}

# Add Apigee Hybrid module
module "apigee_hybrid" {
  source = "../apigee-hybrid-core"

  project_id               = var.project_id
  region                   = var.region
  apigee_org_name          = var.apigee_org_name
  apigee_env_name          = var.apigee_env_name
  apigee_envgroup_name     = var.apigee_envgroup_name
  apigee_namespace         = var.apigee_namespace
  apigee_version           = var.apigee_version
  cluster_name             = local.cluster_name
  
  apigee_org_display_name  = var.apigee_org_display_name
  apigee_env_display_name  = var.apigee_env_display_name
  apigee_instance_name     = var.apigee_instance_name
  apigee_envgroup_hostnames = var.hostnames
  apigee_cassandra_replica_count = var.apigee_cassandra_replica_count
  ingress_name             = var.ingress_name
  ingress_svc_annotations  = var.ingress_svc_annotations
  overrides_template_path  = "${path.module}/../apigee-hybrid-core/overrides-templates.yaml"
  service_template_path    = "${path.module}/../apigee-hybrid-core/apigee-service-template.yaml"
  apigee_install           = var.apigee_install
  create_org               = var.create_org
  billing_type             = var.billing_type

  depends_on = [
    module.eks,
    aws_eks_addon.ebs_csi,
    null_resource.cluster_setup
  ]
}
