//eip 생성
resource "aws_eip" "lb_ip" {
  # instance = aws_instance.web.id
  vpc = true
}
// natgateway 생성
resource "aws_nat_gateway" "explorer_natgate" {
  allocation_id = aws_eip.lb_ip.id
  subnet_id     = aws_subnet.explorer_pub[0].id
  tags = {
    Name = "${var.name}-natgate-a"
  }
}
//라우팅 테이블생성
resource "aws_route_table" "explorer_natgateroutetable" {
  vpc_id = aws_vpc.explorer_vpc.id
  route {
    cidr_block = var.cidr
    gateway_id = aws_nat_gateway.explorer_natgate.id
  }
  tags = {
    Name = "${var.name}-nga-rta"
  }
}
//라우팅 테이블 연결
resource "aws_route_table_association" "explorer_ngartas" {
  count          = "${length(var.private_s)}"
  subnet_id      = aws_subnet.explorer_pri[count.index].id
  route_table_id = aws_route_table.explorer_natgateroutetable.id
}

