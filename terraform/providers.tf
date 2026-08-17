terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.5.0"
    }
  }
}

provider "docker" {}

variable "pg_db" {
  type    = string
  default = "platform"
}

variable "pg_user" {
  type    = string
  default = "platform_user"
}

variable "pg_password" {
  type      = string
  sensitive = true
}


variable "pg_port" {
  type    = number
  default = 5432
}
resource "docker_image" "postgres" {
  name         = "postgres:18"
  keep_locally = false
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "platform"
  env = [
    "POSTGRES_USER=${var.pg_user}",
    "POSTGRES_PASSWORD=${var.pg_password}",
    "POSTGRES_DB=${var.pg_db}"
  ]
  ports {
    internal = var.pg_port
    external = 5433
  }
  networks_advanced {
    name = docker_network.docker_platform.name
  }
  volumes {
    container_path = "/var/lib/postgresql/data"
    volume_name    = docker_volume.postgres_data.name
  }
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}