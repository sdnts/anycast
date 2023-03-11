variable "vultr_api_key" {
  sensitive = true
}

variable "vultr" {
  type = object({
    machine = string
  })
  default = {
    machine = "vhp-1c-1gb-amd"
  }
}

////////////////////////////////

provider "vultr" {
  api_key = var.vultr_api_key
}

data "vultr_os" "debian" {
  filter {
    name   = "name"
    values = ["Debian 11 x64 (bullseye)"]
  }
}

data "vultr_ssh_key" "ssh_key" {
  filter {
    name   = "name"
    values = ["Callisto"]
  }
}

////////////////////////////////

resource "vultr_instance" "nodes" {
  for_each = toset(var.locations)

  plan        = var.vultr.machine
  region      = each.key
  os_id       = data.vultr_os.debian.id
  ssh_key_ids = [data.vultr_ssh_key.ssh_key.id]
  label       = "echo-node-${each.key}"
  hostname    = each.key
  backups     = "disabled"
  tags        = ["echo"]

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for SSH'"
    ]

    connection {
      type        = "ssh"
      host        = self.main_ip
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      agent       = true
      timeout     = "5m"
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook -i ${self.main_ip}, -u root ../ansible/provision.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING    = false
      ECHO_CF_access_client_id     = var.cf_access_client_id
      ECHO_CF_access_client_secret = var.cf_access_client_secret
    }
  }
}
