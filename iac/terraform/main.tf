terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.1.0"
    }

    vultr = {
      source  = "vultr/vultr"
      version = "2.12.1"
    }

    local = {
      source = "hashicorp/local"
    }
  }
}

////////////////////////////////

variable "locations" {
  type = list(string)
  default = [
    "lax", // Los Angeles
    "ewr", // New York
    "scl", // Santiago
    "lhr", // London
    "fra", // Frankfurt
    "jnb", // Johannesburg
    "del", // Delhi
    "sgp", // Singapore
    "nrt", // Tokyo
  ]
}

output "anycast" {
  value = cloudflare_record.anycast.hostname
}

output "nodes" {
  value = {
    for l in var.locations :
    l => vultr_instance.nodes[l].main_ip
  }
}
