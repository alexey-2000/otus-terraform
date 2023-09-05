terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
  }
  
}

locals {
  folder_id = "b1g6kc05t5h2b2pcr4e0"
  cloud_id = "b1g6jvm08etl4nco629l"
  zone_id = "ru-central1-a"
}

provider "yandex" {
  cloud_id = local.cloud_id
  folder_id = local.folder_id
  service_account_key_file = file("~/.ssh/authorized_key.json")
  zone = local.zone_id
}