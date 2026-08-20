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
    container_path = "/var/lib/postgresql"
    volume_name    = docker_volume.postgres_data.name
  }
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}


resource "docker_image" "kafka" {
  name         = "apache/kafka:4.3.1"
  keep_locally = false
}

resource "docker_container" "broker" {
  image = docker_image.kafka.image_id
  name  = "kafka_platform"
  ports {
    internal = 9092
    external = 9092
  }
  env = [
    "KAFKA_NODE_ID=1",
    "CLUSTER_ID=4L6g3nShT-eMCtK--X86sw",
    "KAFKA_PROCESS_ROLES=controller,broker",
    "KAFKA_LISTENERS=INTERNAL://:29092,EXTERNAL://:9092,CONTROLLER://:9093",
    "KAFKA_ADVERTISED_LISTENERS=EXTERNAL://localhost:9092,INTERNAL://kafka_platform:29092",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=EXTERNAL:PLAINTEXT,INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT",
    "KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL",
    "KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER",
    "KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka_platform:9093",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1",
    "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0",
    "KAFKA_NUM_PARTITIONS=1",
    "KAFKA_LOG_DIRS=/var/lib/kafka/data",
    "KAFKA_SHARE_COORDINATOR_STATE_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_SHARE_COORDINATOR_STATE_TOPIC_MIN_ISR=1"
  ]
  networks_advanced {
    name = docker_network.docker_platform.name
  }
  volumes {
    container_path = "/var/lib/kafka/data"
    volume_name    = docker_volume.kafka_data.name
  }
}

resource "docker_volume" "kafka_data" {
  name = "kafka_data"
}