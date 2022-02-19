# Render a part using a `template_file`
data "template_file" "ec2-userdata" {
  template           = "${file("${path.module}/ec2-userdata.sh")}"
  s3_bucket          = var.s3_bucket
  playbook           = var.playbook
  vars_file          = var.vars_file
}

# Render a multi-part cloudinit config making use of the part above, and other source files
data "template_cloudinit_config" "config" {
  gzip              = false
  base64_encode     = true

  part {
    filename        = "ec2-userdata.sh"
    content_type    = "text/x-shellscript"
    content         = data.template_file.ec2-userdata.rendered
  }
}