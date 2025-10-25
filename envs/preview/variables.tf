variable "location" {
  type = string
}

variable "family" {
  type = string
}

variable "repo" {
  type = string
}

variable "devops" {
  type = object({
    storage  = string
    registry = string
  })
}

variable "storage_defaults" {
  type = object({
    tier          = string
    replication   = string
    tls_version   = string
    https_only    = bool
    nested_public = bool
    access        = string
  })
}

variable "azf_defaults" {
  type = object({
    plan_os_type                = string
    plan_sku_name               = string
    functions_extension_version = string
    worker_runtime              = string
    java_version                = string
  })
}

variable "aca_defaults" {
  type = object({
    cpu                       = number
    memory                    = string
    min_replicas              = number
    max_replicas              = number
    ingress_external_enabled  = bool
    ingress_target_port       = number
    ingress_transport         = string
    revision_mode             = string
  })
}
