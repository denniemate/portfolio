//보안그룹 설정
resource "aws_security_group" "explorer_bastionsg"{
  name        = "Allow-bastion"
  description = "ssh"
  vpc_id      = aws_vpc.explorer_vpc.id
 
  ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      protocol         = var.prot_tcp
      cidr_blocks      = ["112.162.204.237/32"]  #my ip 넣으면 됩니다!
     # cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-bastion-sg"
  }
 }

resource "aws_security_group" "explorer_websg"{
  name        = "Allow-WEB"
  description = "http-ssh"
  vpc_id      = aws_vpc.explorer_vpc.id

 ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      protocol         = var.prot_tcp
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      security_groups  = [aws_security_group.explorer_bastionsg.id]
      prefix_list_ids  = null
      self             = null
    },
    {
      description      = var.prot_http
      from_port        = var.http_port
      to_port          = var.http_port
      protocol         = var.prot_tcp
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      security_groups  = [aws_security_group.explorer_albsg.id]
      prefix_list_ids  = null
      self             = null
    }
  ]

 egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-web-sg"
  }
}

resource "aws_security_group" "explorer_wassg"{
  name        = "Allow-WAS"
  description = "tomcat-bastionsg"
  vpc_id      = aws_vpc.explorer_vpc.id
 
ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      protocol         = var.prot_tcp
      security_groups  = [aws_security_group.explorer_bastionsg.id] 
      prefix_list_ids  = null
      self             = null
    },
    {
      description     = "tomcat"
      from_port       = var.tomcat_port
      to_port         = var.tomcat_port
      cidr_blocks     = [var.cidr] //null
      ipv6_cidr_blocks= null
      protocol        = "tcp"
      security_groups = null //[aws_security_group.ldy_websg.id]
      prefix_list_ids = null
      self            = null
    }
  ]

 egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
 tags = {
    Name = "${var.name}-was-sg"
  }
 }

resource "aws_security_group" "explorer_dbsg"{
  name        = "Allow-db"
  description = "mysql-port"
  vpc_id      = aws_vpc.explorer_vpc.id
 ingress = [
 {
      description      = var.prot_sql
      from_port        = var.mysql_port
      to_port          = var.mysql_port
      cidr_blocks      = null
      ipv6_cidr_blocks = null      
      protocol         = var.prot_tcp
      security_groups  = [aws_security_group.explorer_wassg.id]
      prefix_list_ids  = null
      self             = null
    }
 ]
egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-db-sg"
  }
 }

resource "aws_security_group" "explorer_albsg"{
  name        = "Allow-alb"
  description = "http"
  vpc_id      = aws_vpc.explorer_vpc.id
  ingress = [
 {
      description      = var.prot_http
      from_port        = var.http_port
      to_port          = var.http_port
      protocol         = var.prot_tcp
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
]
egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
 tags = {
    Name = "${var.name}-alb-sg"
  }
 }
 
##여기까지 보안그룹 설정##



##bastion ##
//배스천 인스턴스 생성
resource "aws_instance" "explorer_bastion" {

  ami                    = var.ami
  instance_type          = var.instance
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.explorer_bastionsg.id]
  availability_zone      = "${var.region}${var.avazone[0]}"
  private_ip             = var.private_bastionip
  subnet_id              = aws_subnet.explorer_pub[0].id
  user_data              = file("./../01_module/control.sh")
  tags = {
    Name = "${var.name}-bastion"
  }
}
//bastion 인스턴스에 eip 연결
resource "aws_eip" "explorer_bastion_eip" {
 
  vpc                       = true
  instance                  = aws_instance.explorer_bastion.id
  associate_with_private_ip = var.private_bastionip
  depends_on                = [aws_internet_gateway.explorer_igw]

}
##bastion ##


//web 인스턴스 생성
##web ##
resource "aws_instance" "explorer_web" {

  ami                    = var.ami
  instance_type          = var.instance_t2
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.explorer_websg.id]
  availability_zone      = "${var.region}${var.avazone[1]}"
  private_ip             = var.private_ip
  subnet_id              = aws_subnet.explorer_pub[1].id
  user_data              = file("./../01_module/install_web.sh")

  tags = {
    Name = "${var.name}-web"
  }
}
//web 인스턴스에 eip 연결
resource "aws_eip" "explorer_web_eip" {
 
  vpc                       = true
  instance                  = aws_instance.explorer_web.id
  associate_with_private_ip = var.private_ip
  depends_on                = [aws_internet_gateway.explorer_igw]

}


####was

//was 인스턴스 생성
resource "aws_instance" "explorer_wasa" {
    ami                         = var.ami
    instance_type               = var.instance
    key_name                    = var.key
    vpc_security_group_ids      = [aws_security_group.explorer_wassg.id]
    availability_zone           = "ap-northeast-2c"
    private_ip                  = "10.0.2.12"
    subnet_id                   = aws_subnet.explorer_pub[1].id
    user_data                   = file("./../01_module/install_was.sh")

    tags = {
      Name = "${var.name}-was"
    }
}
//was인스턴스에 eip 연결
resource "aws_eip" "explorer_was_eip" {
  vpc = true
  instance = aws_instance.explorer_wasa.id
  associate_with_private_ip = "10.0.2.12"
  depends_on = [aws_internet_gateway.explorer_igw]
  
}

