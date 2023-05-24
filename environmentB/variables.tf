locals {
  template_variables = {
    git_tag     = "some_other_hash"
    hostname    = "B.foo.bar"
    enable_this = true
    optional_vars = {
      var_two = "B has var_two"
    }
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
