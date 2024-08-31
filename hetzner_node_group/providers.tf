terraform {
  required_version = ">= 1.9.5"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.48.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
