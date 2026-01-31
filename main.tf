locals {
  fatline_macos_bin  = "${path.module}/fatline-macos.sh.tftpl"
  fatline_fedora_bin = "${path.module}/fatline-fedora.sh.tftpl"
  includes = {
    LOGGING         = "logging.sh",
    CONFIG_MACOS    = "config/macos.sh",
    CONFIG_FEDORA   = "config/fedora.sh",
    TEMPLATES       = "templates.sh",
    ARGV            = "argv.sh",
    STATE           = "state.sh"
    LIFECYCLE       = "lifecycle.sh",
    SYSTEM_MACOS    = "system/macos.sh",
    SYSTEM_FEDORA   = "system/fedora.sh",
    HOMEBREW        = "homebrew.sh",
    DNF             = "dnf.sh",
    PLAN            = "plan.sh",
    WORKFLOW_MACOS  = "workflow/macos.sh",
    WORKFLOW_FEDORA = "workflow/fedora.sh",
    MAIN            = "main.sh"
  }
}

module "includes" {
  source   = "./modules/include"
  for_each = local.includes

  src  = file("${path.module}/${each.value}")
  path = "./${each.value}"
}

locals {
  template_vars = {
    for name, mod in module.includes : name => mod.include
  }
}

resource "local_file" "fatline_macos" {
  content              = templatefile(local.fatline_macos_bin, local.template_vars)
  filename             = "${path.module}/bin/fatline-macos"
  directory_permission = "0755"
  file_permission      = "0755"
}

resource "local_file" "fatline_fedora" {
  content              = templatefile(local.fatline_fedora_bin, local.template_vars)
  filename             = "${path.module}/bin/fatline-fedora"
  directory_permission = "0755"
  file_permission      = "0755"
}
