# IaC

Infrastructure as code

### Prerequisites

- [Terraform](https://terraform.io)
- [Ansible](https://ansible.com)
- [1Password CLI](https://developer.1password.com/docs/cli/) (optional)

### Steps

0. Store secrets in 1Password (expected paths are in `terraform/.env`). If you aren't using the 1Password CLI, export environment variables with the same names instead.

1. Provision infrastructure (`cd terraform` first):

```bash
op run --env-file=.env -- terraform apply
```

Or, without the 1Password CLI (`cd terraform` first):

```bash
terraform apply
```

3. Deploy code (`cd ansible` first):

```bash
asnsible-playbook deploy.yml
```
