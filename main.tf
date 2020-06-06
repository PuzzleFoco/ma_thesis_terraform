provider "azurerm" {
    version         = "=1.38.0"

    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
}

module "aks" {
    source          = "git::git@gitlab.hrz.tu-chemnitz.de:faeng--tu-chemnitz.de/terraform-azurerm-azurekubernetes.git"

    client_id           = var.client_id
    client_secret       = var.client_secret
    resource_group_name = "examplerg"
    aks_cluster_name    = "examplecluster"
    location            = "West Europe"
    dns_prefix          = "exampledns"
    node_count          = 2
    kube_dashboard      = true
}

provider "kubernetes" {
  version                = "1.10.0"
  load_config_file       = false
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

provider "helm" {
    version = "~>1.0.0"

    kubernetes {
      host                   = module.aks.host
      client_certificate     = base64decode(module.aks.client_certificate)
      client_key             = base64decode(module.aks.client_key)
      cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
      load_config_file       = false
  }
}

module "azurerm_dns_zone" {
    source = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_azurerm_dns_zone.git"

    resource_group_name = "masterthesisrg"
    location            = "West Europe"
    dns_prefix          = "masterthesisdns"
    ip_address_name     = "IPAddressForMasterthesis"
    root_domain         = "masterthesis.online"
}

module "nginx" {
    source         = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_nginx_helm.git"

    controller_service = {
      "enabled"        : "true",
      "loadBalancerIP" : module.azurerm_dns_zone.ip_address,
    }

    annotations    = [
        {
          "annotation_key" : "service.beta.kubernetes.io/azure-load-balancer-resource-group",
          "annotation_value" : "${module.azurerm_dns_zone.dns_resource_group}"
        }
      ]
}

module "jenkins" {
  source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/jenkins_terraform_module.git"

  credentials = var.credentials
  host_name   = "jenkins.${module.azurerm_dns_zone.root_domain}"
}

module "cert-manager" {
  source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_cert_manager_azurerm.git"

  cluster_name            = module.aks.cluster_name
  resource_group_name     = module.aks.resource_group_name
  root_domain             = module.azurerm_dns_zone.root_domain
  dns_zone_resource_group = module.azurerm_dns_zone.dns_resource_group
  lets_encrypt_email      = var.email
  subscription_id         = var.subscription_id
  client_id               = var.client_id
  client_secret           = var.client_secret
  tenant_id               = var.tenant_id
}