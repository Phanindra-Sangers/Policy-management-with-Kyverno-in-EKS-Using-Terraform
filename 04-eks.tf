
module "eks" {

  source                         = "terraform-aws-modules/eks/aws"
  version                        = "20.8.4"
  cluster_name                   = format("%s-%s", local.prefix, local.suffix)
  cluster_version                = var.eks_cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  authentication_mode            = "API_AND_CONFIG_MAP"
  access_entries                 = var.access_entries

  cluster_addons = {

    coredns = {
      preserve    = true
      most_recent = true
    }

    kube-proxy = {
      preserve    = true
      most_recent = true
    }

    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      most_recent              = true
    }

    vpc-cni = {
      preserve    = true
      most_recent = true
    }

    eks-pod-identity-agent = { 

      preserve = true 
      most_recent = true 
    }

  }

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    within_vpc = {
      description = "within_vpc"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }

  }


  #  node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed

    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {

      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {

    core_node_group = {
      name           = var.node_group_name
      description    = "EKS Core node group for hosting critical add-ons"
      subnet_ids     = module.vpc.private_subnets
      min_size       = var.eks_node_min_size
      max_size       = var.eks_node_max_size
      desired_size   = var.eks_node_desired_size
      instance_types = var.eks_instance_types
      ebs_optimized  = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 100
            volume_type = "gp3"
          }
        }
      }

      labels = {
        WorkerType    = "ON_DEMAND"
        NodeGroupType = "core"
      }

      tags = merge({ Name = "core-node-grp" }, local.tags)
    }
  }
}


module "ebs_csi_driver_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "~> 5.34"
  role_name_prefix      = format("%s-%s", local.prefix, "ebs-csi-driver")
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = local.tags
}
