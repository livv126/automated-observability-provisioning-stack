# 게임 서버 인스턴스 프로비저닝
resource "google_compute_instance" "game_server" {
  name         = "zomboid-server-01"
  machine_type = "n2d-highmem-4" 
  zone         = local.zone
  
  tags = ["zomboid-server"] 

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9" 
      size  = 100
      type  = "pd-ssd" 
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.static_ip.address 
    }
    nic_type = "GVNIC" 
  }

  metadata = {
    ssh-keys = "rocky:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Output: 할당된 외부 IP 반환
output "server_ip" {
  value = google_compute_address.static_ip.address
}