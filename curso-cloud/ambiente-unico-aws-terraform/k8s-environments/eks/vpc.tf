module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  create_vpc = true
  name       = "mynetwork"
  cidr       = "10.100.0.0/16"
  # secondary_cidr_blocks                = ["10.1.0.0/16", "10.2.0.0/16"]
  enable_dns_hostnames    = true
  enable_dns_support      = true
  azs                     = ["${var.region}a", "${var.region}b"]
  private_subnets         = ["10.100.1.0/24", "10.100.2.0/24"]
  public_subnets          = ["10.100.10.0/24", "10.100.20.0/24"]
  enable_nat_gateway      = false
  single_nat_gateway      = false
  one_nat_gateway_per_az  = false
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned" // "owned || ""shared"
    "kubernetes.io/role/elb"                          = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}