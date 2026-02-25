# Cloudflare DNS 레코드 등록 (Game Server IP 매핑)
resource "cloudflare_record" "zomboid_dns" {
  zone_id = "5ddf361433b49c89198c6f77a7587c65"
  name    = "zomboid" 
  type    = "A"
  
  content = google_compute_instance.game_server.network_interface[0].access_config[0].nat_ip
  
  # 주의: UDP 트래픽(16261) 차단 방지를 위해 Proxy 비활성화 필수
  proxied = false 
  ttl     = 120 
}