locals {
  template_variables = {
    git_tag     = "some_hash"
    hostname    = "A.foo.bar"
    enable_this = false
  }
}

variable "output_file" {
  type    = string
  default = "output.txt"
}
