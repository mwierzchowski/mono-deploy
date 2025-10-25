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
    storage       = string
    tier          = optional(string, "Standard")
    replication   = optional(string, "LRS")
    tls_version   = optional(string, "TLS1_2")
    https_only    = optional(bool, true)
    nested_public = optional(bool, false)
    access        = optional(string, "private")
    law = object({
      sku       = optional(string, "PerGB2018")
      retention = optional(number, 30)
    })
  })
}
