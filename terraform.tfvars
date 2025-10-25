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
  purge = {
    dev_days     = 1
    stable_count = 10
  }
}

storage_defaults = {
  tier          = "Standard"
  replication   = "LRS"
  tls_version   = "TLS1_2"
  https_only    = true
  nested_public = false
  access        = "private"
}

azf_defaults = {
  plan_os_type                = "Linux"  # Linux/Windows
  plan_sku_name               = "Y1"     # Y1 (Consumption), EP1.. (Premium), S1.. (Dedicated)
  functions_extension_version = "~4"
  worker_runtime              = "java"
  java_version                = "21"
}

aca_defaults = {
  cpu                       = 0.25
  memory                    = "0.5Gi"
  min_replicas              = 0
  max_replicas              = 1
  ingress_external_enabled  = true
  ingress_target_port       = 80
  ingress_transport         = "auto"
  revision_mode             = "Single"
}