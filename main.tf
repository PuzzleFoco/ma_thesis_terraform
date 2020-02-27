provider "azurerm" {
    version = "=1.38.0"

    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
}

// provider "google" {
//     credentials = file("testproject-ef39e40d4d53.json")
//     region  = "europe-west3"
//     zone    = "europe-west3-a"
// }

// module "gke" {
//     source = "git::git@gitlab.hrz.tu-chemnitz.de:faeng--tu-chemnitz.de/terraform-google-kubernetes.git"

//     gke_cluster_name    = "examplecluster"
//     location            = "europe-west3"
//     project             = "testproject-268907"
// }

module "aks" {
    source          = "git::git@gitlab.hrz.tu-chemnitz.de:faeng--tu-chemnitz.de/terraform-azurerm-azurekubernetes.git"

    client_id           = var.client_id
    client_secret       = var.client_secret
    resource_group_name = "examplerg"
    aks_cluster_name    = "examplecluster"
    location            = "West Europe"
    dns_prefix          = "exampledns"
}

// module "acr" {
//     source = "git::git@gitlab.hrz.tu-chemnitz.de:faeng--tu-chemnitz.de/terraform_azurerm_azurecontaierregistry.git"

//     name                = "fabiusacrformaster"
//     resource_group_name = "examplergforacr"
//     location            = "West Europe"
// }

provider "kubernetes" {
  version                = "1.10.0"

  load_config_file = "false"

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

module "nginx" {
    source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_nginx_helm.git"
}

module "jenkins" {
  source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/jenkins_terraform_module.git"
}