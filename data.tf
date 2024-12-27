data "aws_eks_cluster_auth" "default_cluster_auth" {
  name = var.cluster_name
}

