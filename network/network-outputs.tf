output "webapp-vpc-id" {
    value = aws_vpc.webappvpc.id
}

output "private-subnet1-id" {
  value = aws_subnet.subnet1.id
}

output "private-subnet2-id" {
  value = aws_subnet.subnet2.id
}

output "public-subnet3-id" {
  value = aws_subnet.subnet3.id
}

output "instance_sg" {
  value = aws_security_group.web-tier-sg.id
}

output "nlb-ip" {
  value = aws_eip.nlb-ip.id
}

output "dbtier-sg" {
  value = aws_security_group.dbtier-sg.id
}
