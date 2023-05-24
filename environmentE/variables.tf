locals {
  template_variables = {
    git_tag       = "some_hash"
    hostname      = "A.foo.bar"
    optional_vars = {}
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
