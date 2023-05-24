locals {
  template_variables = {
    git_tag     = "C"
    hostname    = "C.foo.bar"
    enable_this = true
    optional_vars = {
      var_one   = "C has both var_one"
      var_three = "... and var_three"
    }
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
