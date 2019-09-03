terraform {
  required_version = ">=0.11.7"
}
provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region = "${var.region}"
}

resource "google_compute_instance" "docker" {
  name         = "docker-app${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  count = "${var.docker_count}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["reddit-app"]

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
}
