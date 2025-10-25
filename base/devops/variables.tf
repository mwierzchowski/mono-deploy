variable "location" {
  type = string
}

variable "family" {
  type = string
}

variable "repo" {
  type = string
}

variable "tfstate" {
  type = object({
    storage = string
  })
}

variable "devops" {
  type = object({
    storage       = string
    registry      = string
    acr_sku       = optional(string, "Basic")
    law_sku       = optional(string, "PerGB2018")
    law_retention = optional(number, 30)
    gha = object({
      org      = string
      ci_repos = list(string)
      ci_env   = string
      cd_env   = string
    })
    purge = object({
      dev_days     = number
      stable_count = number
    })
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
