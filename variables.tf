
variable "subscription_id" {
  description = "The unique identifier of your abonnement"
}

variable "client_id" {
  description = "The unique client id"
}

variable "client_secret" {
  description = "The client secret"
}

variable "tenant_id" {
  description = "The unique identifier of your organization"
}

variable "credentials" {
  description = "credentials for a docker hub account"
  type        = list(any)
}

variable "email" {
  description = "E-Mail Address for letsencrypt"
  type        = string
}