variable "cf_token" {
  sensitive = true
}
variable "cf_access_client_id" {
  sensitive = true
}
variable "cf_access_client_secret" {
  sensitive = true
}

variable "cloudflare" {
  type = object({
    account_id = string
    zone_id    = string
  })
  default = {
    account_id = "80fc72b66f7c5acd95b33a5460f58c88"
    zone_id    = "750b99b779ad59cbef64ac01e67e6de9"
  }
}

////////////////////////////////

provider "cloudflare" {
  api_token = var.cf_token
}

data "cloudflare_zone" "zone" {
  account_id = var.cloudflare.account_id
  zone_id    = var.cloudflare.zone_id
}

////////////////////////////////

resource "cloudflare_record" "anycast" {
  zone_id = var.cloudflare.zone_id
  type    = "CNAME"
  name    = "node"
  value   = data.aws_route53_zone.zone.name
  proxied = true
  ttl     = 1
}
