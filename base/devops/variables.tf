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
    storage          = string
    registry         = string
    law_sku          = optional(string, "PerGB2018")
    law_retention    = optional(number, 30)
    gha = object({
      org      = string
      ci_repos = list(string)
      ci_env   = string
      cd_env   = string
    })
  })
}

variable "storage" {
  type = object({
    tier          = string
    replication   = string
    tls_version   = string
    https_only    = bool
    nested_public = bool
    access        = string
  })
}