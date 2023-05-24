locals {
  our_rendered_content = templatefile("../common-template-file.tftpl", local.template_variables)
}

resource "null_resource" "example" {
  triggers = {
    template = local.our_rendered_content
  }

  # Render to local file on machine
  # https://github.com/hashicorp/terraform/issues/8090#issuecomment-291823613
  provisioner "local-exec" {
    command = format(
      "cat <<\"EOF\" > \"%s\"\n%s\nEOF",
      var.output_file,
      local.our_rendered_content
    )
  }
}
