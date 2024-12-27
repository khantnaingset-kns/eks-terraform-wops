module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 5
      desired_size = 1

    }
  }

  access_entries = {
    eks_iam_user = {
      kubernetes_groups = []
      principal_arn     = var.eks_access_entry_iam_user_arn

      policy_associations = {
        policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "karpenter"
  }
}

resource "kubernetes_namespace" "scaler" {
  metadata {
    name = "karpenter-scaler"
  }
}

resource "helm_release" "this" {
  name       = "karpenter-scaler"
  repository = "https://charts.karpenter.sh/"
  chart      = "karpenter"
  namespace  = kubernetes_namespace.scaler.id
  version = "0.16.3"
  
  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "interruptionQueue"
    value = var.cluster_name
  }

  set {
    name = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }


}
