variable "src" {
  description = "The source code of a shell script"
  type        = string
}

variable "path" {
  description = "The path to the shell script"
  type        = string
  default     = "<unspecified>"
}

variable "interpreter" {
  description = "The interpreter, as seen in a shebang"
  type        = string
  default     = "/usr/bin/env bash"
}
