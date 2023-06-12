data "aws_ami" "amazon2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon2.id
  instance_type = "t4g.small"
  subnet_id     = var.ec2_subnet
  
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    
  }
   lifecycle {
   prevent_destroy = true
 }

  credit_specification {
    cpu_credits = "standard"
  }
}