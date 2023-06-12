

resource "aws_vpc" "test-vpc" {
  cidr_block = var.vpc_cidr_block


  tags = {
    Name = var.Name
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.test-vpc.id
  count             = length(var.public_subnet_cidr)
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]


  tags = {
    Name = var.public1_name
  }
}



resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.test-vpc.id
  count      = length(var.private_subnet_cidr)
  cidr_block = element(var.private_subnet_cidr, count.index)


  tags = {
    Name = "name"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ELB publicRouteTable"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "EC2 privateRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat" {

  tags = {
    Name = "eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.subnet_id
  tags = {
    Name = "gw NAT"
  }


  depends_on = [aws_internet_gateway.igw]
}


resource "aws_security_group" "lb_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # cidr_blocks      = [aws_vpc.test-vpc.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_lb" "front_end" {
  name               = "front-end-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  #   subnets = var.subnet_id_lb




  tags = {
    Environment = "production"
  }
}


resource "aws_lb_target_group" "front_end" {
  name     = "web-server"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test-vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = var.instance_id
  port             = 80
}


resource "aws_network_acl" "EC2_Private_NACL" {
  vpc_id = aws_vpc.test-vpc.id


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "EC2_Private_NACL"
  }
}


resource "aws_network_acl" "ALB_Public_NACL" {
  vpc_id = aws_vpc.test-vpc.id


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "EC2_Private_NACL"
  }
}