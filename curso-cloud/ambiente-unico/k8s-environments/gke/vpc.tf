module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = var.project_id
  network_name = "mynetwork"

  subnets = [
    {
      subnet_name   = "mynetwork-sbn-1"
      subnet_ip     = "10.0.1.0/24"
      subnet_region = var.region
    },
    {
      subnet_name   = "mynetwork-sbn-2"
      subnet_ip     = "10.0.2.0/24"
      subnet_region = var.region
      #   subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    mynetwork-sbn-1 = [
      {
        range_name    = "mynetwork-subnet-gke-pods"
        ip_cidr_range = "192.168.0.0/21"
      },
      {
        range_name    = "mynetwork-subnet-gke-services"
        ip_cidr_range = "172.21.0.0/21"
      }
    ]

    mynetwork-sbn-2 = []
  }
}

module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 5.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  rules = [
    {
      name                    = "${module.vpc.network_name}-allow-internal"
      description             = "internal connection"
      direction               = "INGRESS"
      priority                = 65534
      ranges                  = ["10.0.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = null
        }
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "${module.vpc.network_name}-ssh-from-gcloud-console"
      description             = "ssh connection"
      direction               = "INGRESS"
      priority                = 65533
      ranges                  = ["35.235.240.0/20"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      deny       = []
      log_config = null
    }
  ]
}