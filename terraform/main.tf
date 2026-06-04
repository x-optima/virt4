#main.tf
# Получаем актуальный образ Ubuntu 22.04 LTS из каталога Yandex Cloud
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# Создаем виртуальную машину.
resource "yandex_compute_instance" "server1" {
  name        = "server1"       # Имя ресурса в Yandex Cloud
  hostname    = "server1"       # hostname внутри ВМ
  platform_id = "standard-v3"   # Платформа ВМ
  zone        = "ru-central1-a" # Зона размещения

  # Выделяем ресурсы.
  resources {
    cores         = 2  # 2 vCPU
    memory        = 2  # 2 GB RAM
    core_fraction = 20 # Доля CPU для недорогой ВМ
  }

  # Настройка загрузочного диска
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 15
    }
  }

  # Передаем cloud-init шаблон
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml.tpl", {
      ssh_public_key = var.ssh_public_key
    })
    serial-port-enable = 1
  }

  # Прерываемая ВМ дешевле
  scheduling_policy {
    preemptible = true
  }

  # Подключаем сетевой интерфейс
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.ha_cluster.id]
  }
}

# Генерируем inventory для Ansible локально
resource "local_file" "inventory" {
  content = <<-EOF
[servers]
vm1 ansible_host=${yandex_compute_instance.server1.network_interface.0.nat_ip_address}

[servers:vars]
ansible_user=yc-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOF

  filename = "${path.module}/hosts.ini"
}

# Выводим внешний IP ВМ
output "external_ip" {
  value = yandex_compute_instance.server1.network_interface.0.nat_ip_address
}