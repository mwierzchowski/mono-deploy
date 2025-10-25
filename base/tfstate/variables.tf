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
    storage       = string
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