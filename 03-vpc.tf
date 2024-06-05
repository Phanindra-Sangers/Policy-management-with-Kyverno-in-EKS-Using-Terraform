module "vpc" {

  source                             = "terraform-aws-modules/vpc/aws"
  version                            = "~> 5.0"
  name                               = format("%s-%s-%s", local.prefix, "vpc", local.suffix)
  cidr                               = var.vpc_cidr
  azs                                = local.azs
  private_subnets                    = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 2, k)]     # /26 
  public_subnets                     = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 3, k + 4)] # /27 
  database_subnets                   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 3, k + 6)] # /27  
  create_database_subnet_group       = var.create_db_subnet_group
  create_database_subnet_route_table = var.create_db_subnet_route_table
  enable_nat_gateway                 = var.enable_nat_gw
  single_nat_gateway                 = var.single_nat_gw
  enable_dns_hostnames               = var.enable_dns_hosts
  create_igw                         = var.create_igw

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                               = 1
    "kubernetes.io/cluster/${format("%s-%s", local.prefix, local.suffix)}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                      = 1
    "kubernetes.io/cluster/${format("%s-%s", local.prefix, local.suffix)}" = "owned"
  }

  tags = local.tags
}