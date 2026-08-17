output "network_name" {
  description = "Docker network used by the local data platforms"
  value       = docker_network.docker_platform
}