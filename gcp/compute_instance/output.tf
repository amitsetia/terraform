output "private_ip" {
  value = google_compute_instance.instance[*].network_interface[0].network_ip
}

output "public_ip" {
  value = var.external_ip ? google_compute_instance.instance[*].network_interface[0].access_config[0].nat_ip : null
}


output "instancename" {
  value = google_compute_instance.instance[*].name
}

output "detail" {
  value = zipmap(google_compute_instance.instance[*].name, google_compute_instance.instance[*].network_interface[0].network_ip)
}

