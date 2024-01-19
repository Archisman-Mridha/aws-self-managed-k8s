packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "args" {
  type= object({
    aws_access_key= string
    aws_secret_key= string

    aws_region= string
  })
}

source "amazon-ebs" "amazon_linux_2" {
  ami_name = "k8s-node"
  region = var.args.aws_region

  access_key = var.args.aws_access_key
  secret_key = var.args.aws_secret_key

  instance_type = "t4g.small"

  source_ami_filter {
    most_recent = true
    owners = ["amazon"]

    filters = {
      architecture     = "arm64"
      root-device-type = "ebs"
    }
  }

  ssh_username = "ubuntu"
}

build {
  name = "install-tools"
  sources = ["source.amazon-ebs.amazon_linux_2"]

  provisioner "shell" {
    script = "./scripts/install-tools.sh"
  }
}