location = "northeurope"
family   = "mono"
repo     = "mono-deploy"

tfstate  = {
  storage = "stmonotfstate3d06cffe"
}

github_actions = {
  org      = "mwierzchowski"
  ci_repos = ["mono-jvm"]
  ci_env   = "publisher"
  cd_env   = "deployer"
}

devops = {
  storage = "stmonodevops86457c46"
}
