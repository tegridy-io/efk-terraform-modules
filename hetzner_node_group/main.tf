## --- public ssh key ----------------------------------------------------------

data "hcloud_ssh_key" "nodes" {
  id = var.ssh_public_key
}

## --- placement group ---------------------------------------------------------

resource "hcloud_placement_group" "node" {
  name = format("%s_%s", var.cluster_name, var.node_group)
  type = "spread"
}

## --- nodes -------------------------------------------------------------------

resource "random_id" "node" {
  count       = var.node_count
  prefix      = format("%s-", var.node_prefix)
  byte_length = 2
}

resource "hcloud_server" "node" {
  count = var.node_count

  labels = {
    "cluster"  = var.cluster_name
    "group"    = var.node_group
    "instance" = random_id.node[count.index].hex
  }

  name               = random_id.node[count.index].hex
  image              = "fedora-40"
  rescue             = "linux64"
  server_type        = var.node_type
  location           = var.cluster_location
  ssh_keys           = [data.hcloud_ssh_key.nodes.id]
  placement_group_id = hcloud_placement_group.node.id

  public_net {
    ipv4_enabled = var.public_ipv4
    ipv6_enabled = var.public_ipv6
  }

  network {
    network_id = var.cluster_network
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      ssh_keys,
      rescue,
    ]
  }

  connection {
    host        = var.public_ipv4 ? self.ipv4_address : self.ipv6_address
    timeout     = "5m"
    private_key = file(var.ssh_private_key)
    # Root is the available user in rescue mode
    user = "root"
  }

  # Wait for the server to be available
  provisioner "local-exec" {
    command = "until nc -zv ${var.public_ipv4 ? self.ipv4_address : self.ipv6_address} 22; do sleep 5; done"
  }

  # Copy setup.ign and replace PUBLIC_SSH_KEY variable
  provisioner "file" {
    content     = replace(file("${path.module}/files/setup.ign"), "PUBLIC_SSH_KEY", trimspace(data.hcloud_ssh_key.nodes.public_key))
    destination = "/root/setup.ign"
  }

  # Get coreos-installer binary
  provisioner "remote-exec" {
    inline = [
      "wget https://s3.eu-central-2.amazonaws.com/tegridy-assets/coreos-installer -O /usr/local/bin/coreos-installer",
      "chmod +x /usr/local/bin/coreos-installer",
      "coreos-installer install /dev/sda -i /root/setup.ign",
      "reboot"
    ]
  }

  # Wait for the server to be available
  provisioner "local-exec" {
    command = "until nc -zv ${var.public_ipv4 ? self.ipv4_address : self.ipv6_address} 22; do sleep 15; done"
  }

  # Configure CoreOS after installation
  provisioner "remote-exec" {
    connection {
      host = var.public_ipv4 ? self.ipv4_address : self.ipv6_address
      timeout = "1m"
      private_key = file(var.ssh_private_key)
      # This user is configured in setup.yaml
      user = "core"
    }

    inline = [
      "sudo hostnamectl set-hostname ${self.name}"
      # Add additional commands if needed
    ]
  }
}
