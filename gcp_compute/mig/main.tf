
locals {
  healthchecks = concat(
    google_compute_health_check.https.*.self_link,
    google_compute_health_check.http.*.self_link,
    google_compute_health_check.tcp.*.self_link,
  )
  distribution_policy_zones_base = {
    default = data.google_compute_zones.available.names
    user    = var.distribution_policy_zones
  }
  distribution_policy_zones = local.distribution_policy_zones_base[length(var.distribution_policy_zones) == 0 ? "default" : "user"]

}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_region_instance_group_manager" "mig" {
  provider           = google-beta
  base_instance_name = var.hostname
  project            = var.project_id

  version {
    name              = "${var.hostname}-mig-version-0"
    instance_template = var.instance_template
  }

  name   = var.mig_name == "" ? "${var.hostname}-mig" : var.mig_name
  region = var.region
  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = lookup(named_port.value, "name", null)
      port = lookup(named_port.value, "port", null)
    }
  }
  target_pools = var.target_pools
  target_size  = var.target_size

  wait_for_instances = var.wait_for_instances

  dynamic "auto_healing_policies" {
    for_each = local.healthchecks
    content {
      health_check      = auto_healing_policies.value
      initial_delay_sec = var.health_check["initial_delay_sec"]
    }
  }

  dynamic "stateful_disk" {
    for_each = var.stateful_disks
    content {
      device_name = stateful_disk.value.device_name
      delete_rule = lookup(stateful_disk.value, "delete_rule", null)
    }
  }

  distribution_policy_zones = local.distribution_policy_zones
  dynamic "update_policy" {
    for_each = var.update_policy
    content {
      instance_redistribution_type = lookup(update_policy.value, "instance_redistribution_type", null)
      max_surge_fixed              = lookup(update_policy.value, "max_surge_fixed", null)
      max_surge_percent            = lookup(update_policy.value, "max_surge_percent", null)
      max_unavailable_fixed        = lookup(update_policy.value, "max_unavailable_fixed", null)
      max_unavailable_percent      = lookup(update_policy.value, "max_unavailable_percent", null)
      min_ready_sec                = lookup(update_policy.value, "min_ready_sec", null)
      replacement_method           = lookup(update_policy.value, "replacement_method", null)
      minimal_action               = update_policy.value.minimal_action
      type                         = update_policy.value.type
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [distribution_policy_zones]
  }

  timeouts {
    create = var.mig_timeouts.create
    update = var.mig_timeouts.update
    delete = var.mig_timeouts.delete
  }

}


resource "google_compute_health_check" "https" {
  count   = var.health_check["type"] == "https" ? 1 : 0
  project = var.project_id
  name    = var.health_check_name == "" ? "${var.hostname}-https-healthcheck" : var.health_check_name

  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  timeout_sec         = var.health_check["timeout_sec"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  https_health_check {
    port         = var.health_check["port"]
    request_path = var.health_check["request_path"]
    host         = var.health_check["host"]
    response     = var.health_check["response"]
    proxy_header = var.health_check["proxy_header"]
  }
}

resource "google_compute_health_check" "http" {
  count   = var.health_check["type"] == "http" ? 1 : 0
  project = var.project_id
  name    = var.health_check_name == "" ? "${var.hostname}-http-healthcheck" : var.health_check_name

  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  timeout_sec         = var.health_check["timeout_sec"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  http_health_check {
    port         = var.health_check["port"]
    request_path = var.health_check["request_path"]
    host         = var.health_check["host"]
    response     = var.health_check["response"]
    proxy_header = var.health_check["proxy_header"]
  }

  log_config {
    enable = var.health_check["enable_logging"]
  }
}

resource "google_compute_health_check" "tcp" {
  count   = var.health_check["type"] == "tcp" ? 1 : 0
  project = var.project_id
  name    = var.health_check_name == "" ? "${var.hostname}-tcp-healthcheck" : var.health_check_name

  timeout_sec         = var.health_check["timeout_sec"]
  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  tcp_health_check {
    port         = var.health_check["port"]
    request      = var.health_check["request"]
    response     = var.health_check["response"]
    proxy_header = var.health_check["proxy_header"]
  }

  log_config {
    enable = var.health_check["enable_logging"]
  }
}
