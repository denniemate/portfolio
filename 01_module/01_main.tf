provider "aws" {
  region = var.region
}
/*
resource "aws_key_pair" "jch_key" {
  key_name   = var.key
  public_key = file("../../../.ssh/id_rsa.pub")

}
*/
//vpc 생성
resource "aws_vpc" "explorer_vpc" {
  cidr_block           = var.cidr_main
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }

}
//public subnet 생성
resource "aws_subnet" "explorer_pub" {
  vpc_id            = aws_vpc.explorer_vpc.id
  count             = length(var.public_s)
  cidr_block        = var.public_s[count.index]
  availability_zone = "${var.region}${var.avazone[count.index]}"
  tags = {
    Name = "pub-${var.avazone[count.index]}"
  }
}

//private subnet 생성
resource "aws_subnet" "explorer_pri" {
  vpc_id            = aws_vpc.explorer_vpc.id
  count             = length(var.private_s)
  cidr_block        = var.private_s[count.index]
  availability_zone = "${var.region}${var.avazone[count.index]}"
  tags = {
    Name = "pri-${var.avazone[count.index]}"
  }
}

//private db subnet 생성
resource "aws_subnet" "explorer_pri_db" {
  vpc_id            = aws_vpc.explorer_vpc.id
  count             = length(var.private_dbs)
  cidr_block        = var.private_dbs[count.index]
  availability_zone = "${var.region}${var.avazone[count.index]}"
  tags = {
    Name = "pridb-${var.avazone[count.index]}"
  }
}
// intergateway 생성
resource "aws_internet_gateway" "explorer_igw" {
  vpc_id = aws_vpc.explorer_vpc.id

  tags = {
    Name = "${var.name}-igw"
  }
}

// 라우팅 테이블 생성
resource "aws_route_table" "explorer_rt" {
  vpc_id = aws_vpc.explorer_vpc.id

  route {
    // carrier_gateway_id = "value"
    cidr_block = var.cidr
    // destination_prefix_list_id = "value"
    // egress_only_gateway_id = "value"
    gateway_id = aws_internet_gateway.explorer_igw.id
    // instance_id = "value"
    // ipv6_cidr_block = "value"
    // local_gateway_id = "value"
    // nat_gateway_id = "value"
    // network_interface_id = "value"
    // transit_gateway_id = "value"
    // vpc_endpoint_id = "value"
    // vpc_peering_connection_id = "value"
  }
  tags = {
    Name = "${var.name}-rt"
  }
}
// 라우팅테이블에 서브넷 연결
resource "aws_route_table_association" "explorer_rtas_a" {
  count          = length(var.public_s)
  subnet_id      = aws_subnet.explorer_pub[count.index].id
  route_table_id = aws_route_table.explorer_rt.id
}
