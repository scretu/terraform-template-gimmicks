locals {
  template_variables = {
    git_tag       = "some_hash"
    hostname      = "E.foo.bar"
    optional_vars = {}
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
