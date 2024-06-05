module "eks_blueprints_addons" {

  source            = "aws-ia/eks-blueprints-addons/aws"
  version           = "1.16.2"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn


  enable_aws_load_balancer_controller = true 

  tags = local.tags
}


