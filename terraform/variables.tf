# variables.tf

variable "flow" {
  description = "Environment name: dev/stg/prod"
  type        = string
  default     = "dev"
}

variable "zone" {
  description = "Availability zone for the VM"
  type        = string
  default     = "ru-central1-a"
}

variable "cloud_id" {
  description = "Yandex Cloud cloud ID"
  type        = string
  sensitive   = true
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  sensitive   = true
}

variable "service_account_key_file" {
  description = "Path to Yandex Cloud service account key JSON"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for yc-user"
  type        = string
}

variable "vm_resources" {
  description = "VM sizing (cores, memory, core_fraction)"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}