location = "northeurope"
family   = "mono"
repo     = "mono-deploy"

tfstate  = {
  storage = "stmonotfstate3d06cffe"
}

devops = {
  storage  = "stmonodevops86457c46"
  registry = "acrmonodevops86457c46"
  gha = {
    org      = "mwierzchowski"
    ci_repos = ["mono-jvm"]
    ci_env   = "publisher"
    cd_env   = "deployer"
  }
}

storage = {
  tier          = "Standard"
  replication   = "LRS"
  tls_version   = "TLS1_2"
  https_only    = true
  nested_public = false
  access        = "private"
}