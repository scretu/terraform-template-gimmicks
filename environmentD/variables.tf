locals {
  template_variables = {
    git_tag     = "some_hash"
    hostname    = "D.foo.bar"
    enable_this = false
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
