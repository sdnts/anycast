variable "aws_access_key" {
  sensitive = true
}

variable "aws_secret_key" {
  sensitive = true
}

variable "aws" {
  type = object({
    zone_id = string
  })
  default = {
    zone_id = "Z06658611V52UGJ980W0T"
  }
}

////////////////////////////////

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_route53_zone" "zone" {
  zone_id = var.aws.zone_id
}

////////////////////////////////

resource "aws_route53_record" "records" {
  for_each = {
    // Map from our locations to closest AWS regions
    "lax" = "us-west-1"
    "ewr" = "us-east-1"
    "scl" = "sa-east-1"
    "lhr" = "eu-west-2"
    "fra" = "eu-central-1"
    "jnb" = "af-south-1"
    "del" = "ap-south-1"
    "sgp" = "ap-southeast-1"
    "nrt" = "ap-northeast-1"
  }

  zone_id        = var.aws.zone_id
  type           = "A"
  name           = data.aws_route53_zone.zone.name
  records        = [vultr_instance.nodes[each.key].main_ip]
  set_identifier = each.key
  ttl            = 3600

  latency_routing_policy {
    region = each.value
  }
}
