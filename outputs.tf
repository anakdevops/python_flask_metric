output "public_ip" {
    value = aws_instance.ec2_anakdevops.public_ip
}
output "public_dns" {
    value = aws_instance.ec2_anakdevops.public_dns
}
