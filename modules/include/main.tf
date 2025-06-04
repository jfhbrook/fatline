locals {
  banner  = <<EOT

#
# include: ${var.path}
#

EOT
  include = "${local.banner}${replace(var.src, "#!${var.interpreter}", "")}"
}
