# VPC 및 Subnet 구성
resource "google_compute_network" "vpc_network" {
  name                    = "zomboid-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "zomboid-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = local.region
  network       = google_compute_network.vpc_network.id
}

# 외부 고정 IP 할당
resource "google_compute_address" "static_ip" {
  name   = "zomboid-static-ip"
  region = local.region
}

# 방화벽: Zomboid 게임 포트 허용 (Global)
resource "google_compute_firewall" "allow_game_traffic" {
  name    = "allow-zomboid-game"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "udp"
    ports    = ["16261", "16262"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["zomboid-server"]
}

# 방화벽: 관리자 SSH 접근 허용
resource "google_compute_firewall" "allow_ssh_admin" {
  name    = "allow-ssh-admin"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.admin_ip] 
  target_tags   = ["zomboid-server"]
}

# 방화벽: ELK 스택 모니터링 접근 허용
resource "google_compute_firewall" "elk_monitoring_access" {
  name    = "allow-elk-monitoring"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5601", "5044"] 
  }

  source_ranges = ["100.64.0.0/10"] 
  target_tags   = ["log-server"]
}

# 방화벽: Tailscale Direct Connection 허용
resource "google_compute_firewall" "tailscale_udp" {
  name    = "allow-tailscale-udp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "udp"
    ports    = ["41641"]
  }

  source_ranges = ["0.0.0.0/0"]
}