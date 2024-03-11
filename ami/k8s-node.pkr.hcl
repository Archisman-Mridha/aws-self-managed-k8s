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
    access_key= string
    secret_key= string

    region= string
  })
}

source "amazon-ebs" "amazon_linux_2" {
  ami_name = "k8s-node"
  region = var.args.region

  access_key = var.args.access_key
  secret_key = var.args.secret_key

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