resource "local_file" "inventory" {
  filename = "../ansible/inventory.cfg"
  content = join("\n", [
    for l in var.locations :
    "${l} ansible_host=${vultr_instance.nodes[l].main_ip}"
  ])
}
