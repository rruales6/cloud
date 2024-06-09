# listar regiones: 
# az account list-locations --output table
# listar versiones soportads por alguna region: 
# az aks get-versions --location eastus --output table

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "~>4.0"

  resource_group_name              = azurerm_resource_group.this.name
  kubernetes_version               = "1.25.6"
  orchestrator_version             = "1.25.6"
  prefix                           = "myaks"
  cluster_name                     = "myaks"
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  os_disk_size_gb                  = 30
  sku_tier                         = "Free" # defaults to Free, maybe Paid
  network_plugin                   = "kubenet"
  net_profile_pod_cidr             = "192.168.0.0/21"
  enable_role_based_access_control = false
  private_cluster_enabled          = false
  enable_http_application_routing  = false
  enable_azure_policy              = true
  enable_auto_scaling              = false
  network_policy                   = null # "calico" #null
  agents_min_count                 = 1
  agents_max_count                 = 4
  agents_count                     = 1 # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 30
  agents_pool_name                 = "system"
  agents_size                      = "Standard_A4_v2"
  agents_availability_zones        = ["1", "2"]
  enable_log_analytics_workspace   = false

  agents_labels = {
    "node" : "system"
  }

  enable_ingress_application_gateway      = true
  ingress_application_gateway_name        = "aks-agw-2"
  ingress_application_gateway_subnet_cidr = "10.52.3.0/24"

  depends_on = [module.network]
}

resource "azurerm_public_ip_prefix" "example" {
  name                = "acceptanceTestPublicIpPrefix1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  prefix_length = 31

  tags = {
    environment = "Production"
  }
}

module "aks-node-pool" {
  source  = "guidalabs/aks-node-pool/azure"
  version = "0.1.6"

  resource_group_name   = azurerm_resource_group.this.name
  orchestrator_version  = "1.25.6"
  location              = var.region
  vnet_subnet_id        = module.network.vnet_subnets[0]
  kubernetes_cluster_id = module.aks.aks_id

  node_pools = {
    workloads = {
      vm_size             = "Standard_A4_v2"
      enable_auto_scaling = false
      os_disk_size_gb     = 30
      node_count          = 1
      # min_count                = 1
      # max_count                = 3
      availability_zones    = ["1", "2"]
      enable_node_public_ip = true #false # if set to true node_public_ip_prefix_id is required
      # node_public_ip_prefix_id = module.public-ip-prefix.prefix_id[0]
      node_public_ip_prefix_id = "" #azurerm_public_ip_prefix.example.ip_prefix
      node_labels              = { "node" = "workloads" }
      # node_taints              = ["workload=example:NoSchedule"]
      max_pods    = 50
      agents_tags = {}
    }
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "./kubeconfig"
  content  = module.aks.kube_config_raw
}

output "api_aks" {
  value = module.aks.host
}