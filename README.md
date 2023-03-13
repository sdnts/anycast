# anycast

This is a barebones sandbox for experimenting with anycast networks.
I built this for my own use, but I'm putting it out in the world in case it proves
useful for anyone else.

This is very much not meant to be a "just works" kinda deal. I encourage you to
read all code in the `iac` folder, and copy / adapt it to your use case. Remember
to set up environment variables and change hard-coded IDs! Please feel free to ask
questions here on [GitHub](https://github.com/sdnts/anycast/discussions) or DM me
on social media (links on my profile).

Exact provisioning instructions are [here](./iac/README.md)

### Overview

I think a high-level overview will help you understand what's going on and where
to start looking. Terraform's entrypoint is in `iac/terraform/main.tf`, and I suggest
you start there. Here is what happens (broadly) when you `terraform apply`.

Terraform spins up 9 [Vultr](https://vultr.com) Debian servers in these locations:

- Los Angeles, USA (`lax`)
- New York, USA (`ewr`)
- London, UK (`lhr`)
- Frankfurt, Germany (`fra`)
- New Delhi, India (`del`)
- Singapore, Singapore (`sgp`)
- Tokyo, Japan (`nrt`)
- Santiago, Chile (`scl`)
- Johannesburg, South Africa (`jnb`)

Vultr was chosen because it is the best at balancing geographical distribution
with price in my opinion. I would jump to Hetzner if it expands its locations in
the future. Alternatives considered:

| Provider      | Hardware  | Bandwidth | Locations    |
| ------------- | --------- | --------- | ------------ |
| AWS EC2       | expensive | expensive | excellent    |
| Azure         | expensive | expensive | excellent    |
| Digital Ocean | cheap     | expensive | eh           |
| GCP           | expensive | expensive | excellent    |
| Hetzner       | cheap     | cheap     | US & EU only |
| Vultr         | cheap     | moderate  | excellent    |

Locations were chose mostly on gut-feeling, to maximize reach geographically.
Location codes are the IATA codes of the nearest airports mostly. They also match
up Vultr locations, which makes `for_each`es in Terraform easier.

With these servers up and running, Terraform will write an [Ansible](https://ansible.com)
inventory file, and run the `provision.yml` playbook to provision each server.
It will set up a base level of security, which means SSH (using your private key)
& UFW. It will also install a [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/)
agent that can be configured to send metrics / logs to a location of your choosing.
Right now, it is hard-coded to send it to my analytics server (which will reject
them because you won't have the right access token).

Next up, Terraform will set up 9 `A` records on a zone on [Route53](https://aws.amazon.com/route53/),
which will use its Latency-based routing policy. It will also set up a `CNAME`
record on a different zone on [Cloudflare](https://cloudflare.com). The idea is
that you'd hit this Cloudflare URL to get to the "nearest" (latency-wise) server.
Technically you can get away with just one domain on Route53, but I think Cloudflare
provides a pretty solid first line of defense. I would definitely add some level
of obscurity to the Route53 domain so it isn't easily guessable though, because it
can be used to bypass Cloudflare if it gets revealed.

With this done, your network infrastructure is ready! Next, you'll want to deploy
an HTTP server, which is also provided. Running the `deploy.yml` Ansible playbook
will copy and fire up your server. Hitting your anycast URL now (it should be printed
to stdout as a Terraform output variable) will automatically route your request
to one of the 9 servers, based on latency.

One rough-edge with the `deploy.yml` playbook right now is that it needs the `echo`
binary in the `ansible` folder so it can copy it to all 9 servers. You have to manually
place it there right now. If you're not on Linux, I've set up a GitHub action that
will (statically!) compile the `echo` server and spit out an artifact that you can
download and put in the right place.

Secrets for all of this are managed in 1Password and accessed using the
[1Password CLI](https://developer.1password.com/docs/cli/) for ease of use. You
will of course have to set them yourself, in your own 1Password vault (or just
as environment variables)
