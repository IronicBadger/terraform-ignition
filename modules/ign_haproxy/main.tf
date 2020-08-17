data "ignition_systemd_unit" "haproxy" {
  name    = "haproxy.service"
  content = file("${path.module}/haproxy.service")
}

data "ignition_filesystem" "root" {
  name = "root"
  path = "/"
}

data "ignition_file" "haproxy" {
  filesystem = "root"
  path       = "/etc/haproxy/haproxy.conf"
  mode       = "420" // 0644
  content {
    content = templatefile("${path.module}/haproxy.tmpl", {
      lb_ip_address = var.lb_ip_address,
      api           = var.api_backend_addresses,
      ingress       = var.ingress
    })
  }
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = [file("/Users/alex/.ssh/id_ed25519.pub")]
}

data "ignition_config" "lb" {
  users   = [data.ignition_user.core.rendered]
  files   = [data.ignition_file.haproxy.rendered]
  systemd = [data.ignition_systemd_unit.haproxy.rendered]
}

