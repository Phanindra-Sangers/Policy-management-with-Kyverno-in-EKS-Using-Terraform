module "kyverno" {

  depends_on = [ module.eks ]
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  description      = "Kyverno Kubernetes Native Policy Management"
  chart            = "kyverno"
  chart_version    = "3.0.0"
  namespace        = "kyverno"
  create_namespace = true
  repository       = "https://kyverno.github.io/kyverno/"
}

module "kyverno_policies" {
  depends_on = [ module.kyverno ]
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  description   = "Kyverno policy library"
  chart         = "kyverno-policies"
  chart_version = "3.0.0"
  namespace     = "kyverno"
  repository    = "https://kyverno.github.io/kyverno/"
  values = [
    <<-EOT
          podSecurityStandard: privileged
        EOT
  ]


}

module "policy_reporter" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  description   = "Kyverno Policy Reporter which shows policy reports in a graphical web-based front end."
  chart         = "policy-reporter"
  chart_version = "1.3.0"
  namespace     = "kyverno"
  repository    = "https://kyverno.github.io/policy-reporter/"

  depends_on = [module.kyverno_policies]
}