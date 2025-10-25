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

variable "github_actions" {
  type = object({
    org      = string
    ci_repos = list(string)
    ci_env   = string
    cd_env   = string
  })
}
