variable "family" {
  type = string
}

variable "devops" {
  type = object({
    suffix = string
    github = object({
      org = string
      integration = object({
        repos = list(string)
        env   = string
      })
      deployment = object({
        repo = string
        env  = string
      })
    })
  })
}
