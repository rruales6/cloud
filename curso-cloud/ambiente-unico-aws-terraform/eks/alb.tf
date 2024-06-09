resource "aws_iam_role" "role_loadbalancer_controller" {
  count              = var.aws_load_balancer_controller_enabled ? 1 : 0
  name               = "role-loadbalancer-controller"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Principal": {
          "Federated": [
            "${module.eks.oidc_provider_arn}"
          ]
        },
        "Condition": {
          "StringEquals": {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "loadbalancer_controller" {
  count  = var.aws_load_balancer_controller_enabled ? 1 : 0
  role   = aws_iam_role.role_loadbalancer_controller[0].name
  name   = "LoadBalancerController"
  policy = file("configs/alb-controller/policy.json")
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller_enabled ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.role_loadbalancer_controller[0].arn
    }
  }

  #   automount_service_account_token = true
}

resource "helm_release" "aws_load_balancer_controller" {
  count      = var.aws_load_balancer_controller_enabled ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  timeout         = 240
  cleanup_on_fail = true
  force_update    = false
  namespace       = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}