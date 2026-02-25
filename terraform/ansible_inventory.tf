# Ansible Inventory 자동 생성
resource "local_file" "ansible_inventory" {
  filename = "../zomboid-ansible/inventory.ini"
  
  content  = <<EOT
[control_node]
control-node ansible_connection=local

[log_plane]
log-node ansible_host=10.0.10.2 ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[game_plane]
${google_compute_address.static_ip.address} ansible_user=rocky ansible_ssh_private_key_file=~/.ssh/id_rsa

[all_nodes:children]
control_node
log_plane
game_plane
EOT
}