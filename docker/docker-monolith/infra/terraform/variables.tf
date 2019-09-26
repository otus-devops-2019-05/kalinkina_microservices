variable project {
  description = "Project ID"
}

variable region {
  description = "Region"

  # Значение по умолчанию
  default = "europe-west1"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key {
  description = "Path to the private key used for ssh access"
}

variable zone {
  description = "zone"
}

variable "docker_count" {
  description = "Count of provisioned application nodes"
}
