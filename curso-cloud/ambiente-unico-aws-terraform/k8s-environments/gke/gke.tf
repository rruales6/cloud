module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~>21.0"

  project_id                 = var.project_id
  kubernetes_version         = "1.25"
  name                       = "mygke-cluster"
  region                     = var.region
  zones                      = ["${var.region}-b", "${var.region}-c"]
  network                    = module.vpc.network_name
  subnetwork                 = "mynetwork-sbn-1"
  ip_range_pods              = "mynetwork-subnet-gke-pods"
  ip_range_services          = "mynetwork-subnet-gke-services"
  remove_default_node_pool   = true
  http_load_balancing        = true
  network_policy             = false # true
  horizontal_pod_autoscaling = true
  node_metadata              = "GKE_METADATA_SERVER"
  cluster_autoscaling        = { "enabled" : false, "gpu_resources" : [], "max_cpu_cores" : 0, "max_memory_gb" : 0, "min_cpu_cores" : 0, "min_memory_gb" : 0 }

  node_pools = [
    {
      name           = "system"
      machine_type   = "n1-standard-2"
      node_locations = "${var.region}-b,${var.region}-c"
      min_count      = 1
      max_count      = 5
      node_count     = 2
      disk_size_gb   = 20
      disk_type      = "pd-standard"
      auto_upgrade   = true
    },
    {
      name           = "workloads"
      machine_type   = "n1-standard-2"
      node_locations = "${var.region}-b,${var.region}-c"
      min_count      = 1
      max_count      = 5
      node_count     = 2
      disk_size_gb   = 20
      disk_type      = "pd-standard"
      auto_upgrade   = true
    }
  ]

  node_pools_labels = {
    system = {
      node = "system"
    },
    workloads = {
      node = "workloads"
    }
  }

  #   node_pools_taints = {
  #     mypool = [
  #       {
  #         key    = "pool-01-example"
  #         value  = true
  #         effect = "PREFER_NO_SCHEDULE"
  #       },
  #     ]
  #   }

  # node_pools_tags = {
  #   mypool = [
  #     "example",
  #   ]
  # }
}

resource "local_sensitive_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "./kubeconfig"
}