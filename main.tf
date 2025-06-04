locals {
  fatline_bin = "${path.module}/fatline.sh.tftpl"
  includes = {
    LOGGING   = "logging.sh",
    TEMPLATES = "templates.sh",
    ARGV      = "argv.sh",
    STATE     = "state.sh"
    LIFECYCLE = "lifecycle.sh",
    SYSTEM    = "system.sh",
    HOMEBREW  = "homebrew.sh",
    PLAN      = "plan.sh",
    MAIN      = "main.sh"
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

resource "local_file" "fatline_bin" {
  content              = templatefile(local.fatline_bin, local.template_vars)
  filename             = "${path.module}/bin/fatline"
  directory_permission = "0755"
  file_permission      = "0755"
}
