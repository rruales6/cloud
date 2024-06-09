data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}

module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "~>19.0"
  create                               = true
  cluster_name                         = local.eks_cluster_name
  subnet_ids                           = module.vpc.public_subnets
  cluster_version                      = "1.25"
  vpc_id                               = module.vpc.vpc_id
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["${chomp(data.http.myip.body)}/32"]
  manage_aws_auth_configmap            = true
  create_aws_auth_configmap            = false

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ebs-csi-role-curso"
    }
    # coredns = {
    #   resolve_conflicts = "OVERWRITE"
    # }
    # kube-proxy = {}
    # vpc-cni = {
    #   resolve_conflicts = "OVERWRITE"
    # }
    # adot = {
    #   resolve_conflicts = "OVERWRITE"
    # }
  }

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64" # "AL2_ARM_64"
    disk_size = 25
  }

  node_security_group_additional_rules = {
    all_internal_in = {
      description = "all inbound"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["10.100.0.0/16"]
    }
    all_controlplane_in = {
      description                   = "all inbound"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # all_internal_out = {
    #   description = "all outbound"
    #   protocol    = "-1"
    #   from_port   = 0
    #   to_port     = 0
    #   type        = "egress"
    #   cidr_blocks = ["0.0.0.0/0"]
    # }
  }

  eks_managed_node_groups = {
    system = {
      name                  = "system"
      use_name_prefix       = true
      capacity_type         = "ON_DEMAND" # "SPOT" # "ON_DEMAND"
      desired_size          = 1
      max_size              = 4
      min_size              = 0
      instance_types        = ["t3.medium"]
      force_update_version  = true
      enable_monitoring     = false
      ebs_optimized         = false
      create_security_group = false

      # taints = [
      #     {
      #       key    = "dedicated"
      #       value  = "gpuGroup"
      #       effect = "NO_SCHEDULE"
      #     }
      # ]

      additional_tags = {
        node_group = "system"
      }

      labels = {
        node = "system"
      }
    }

    workloads = {
      name                  = "workloads"
      use_name_prefix       = true
      capacity_type         = "ON_DEMAND" # "SPOT" # "ON_DEMAND"
      desired_size          = 1
      max_size              = 3
      min_size              = 0
      instance_types        = ["t3.medium"]
      force_update_version  = true
      enable_monitoring     = false
      ebs_optimized         = false
      create_security_group = false

      # taints = [
      #     {
      #       key    = "dedicated"
      #       value  = "gpuGroup"
      #       effect = "NO_SCHEDULE"
      #     }
      # ]

      additional_tags = {
        node_group = "workloads"
      }

      labels = {
        node = "workloads"
      }
    }
  }

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      username = "root"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::120654699927:role/AWSReservedSSO_AdministratorAccess_213eb9b842de4be7"
      username = "wmarchan@tulkitpay.com"
      groups   = ["system:masters"]
    }
  ]
}

resource "local_sensitive_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "./kubeconfig"
}