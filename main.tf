locals {
  vm01_name = "tf-vm01"
  vm02_name = "tf-vm02"
  os_image_id = "fd82sqrj4uk9j7vlki3q"
  ssh-key_id = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  zone_id = "ru-central1-a"

}

resource "yandex_compute_instance" "vm-1" {
  name = local.vm01_name
  hostname = local.vm01_name
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = local.os_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = local.ssh-key_id
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = local.vm02_name
  hostname = local.vm02_name
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = local.os_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = local.ssh-key_id
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = local.zone_id
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

data "template_file" "inventory" {
    template = file("./ansible/inventory.tpl")
  
    vars = {
        user = "ubuntu"
        host1 = join("", [yandex_compute_instance.vm-1.name, " ansible_host=", yandex_compute_instance.vm-1.network_interface.0.nat_ip_address])
        host2 = join("", [yandex_compute_instance.vm-2.name, " ansible_host=", yandex_compute_instance.vm-2.network_interface.0.nat_ip_address])
    }
}

resource "local_file" "save_inventory" {
   content  = data.template_file.inventory.rendered
   filename = "./ansible/hosts"
}