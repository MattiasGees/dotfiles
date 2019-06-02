provider "hcloud" {
}

resource "hcloud_server" "workstation" {
  name        = "workstation"
  image       = "ubuntu-18.04"
  server_type = "cx21"
  datacenter  = "nbg1-dc3"
  ssh_keys    = ["mattias.gees@gmail.com"]

  provisioner "remote-exec" {
    script = "bootstrap.sh"

    connection {
      type        = "ssh"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "pull-secrets.sh"
    destination = "/mnt/secrets/pull-secrets.sh"

    connection {
      type        = "ssh"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /mnt/secrets/pull-secrets.sh",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      timeout     = "2m"
    }
  }

}
