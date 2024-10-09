output "instance-data" {
  value = {
    server_a_Ip         = aws_instance.server_a.public_ip
    server_a_publicDNS  = aws_instance.server_a.public_dns
    server_b_Ip         = aws_instance.server_b.private_ip
    server_b_privateDNS = aws_instance.server_b.private_dns
  }
}