variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "admin_ip" {
  description = "SSH 접속을 허용할 관리자 공인 IP (CIDR 포맷, 예: 123.45.67.89/32)"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true # Terraform 로그 화면에 노출되는 것을 방지
}