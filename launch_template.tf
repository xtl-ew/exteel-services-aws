data "aws_ami" "ec2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # AWS
}

resource "aws_ebs_volume" "xtl_db" {
  availability_zone = "${var.region}a"
  size              = 5
  type              = "gp2"
  

  tags = {
    Name = "xteel-db"
  }
}

resource "aws_security_group" "www_to_ec2_nlb" {
  name        = "xtlgame-sg"
  description = "one sg to rule them all"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port       = 8112
    to_port         = 8112
    protocol        = "tcp"
    cidr_blocks     = flatten([[aws_vpc.web_vpc.cidr_block],var.admin_ips])
  }

  ingress {
    from_port       = 15152
    to_port         = 15152
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

data "template_file" "gamehost" {
  template = file("${path.module}/userdata/gamehost.tpl")
  vars = {
    disk_id       = aws_ebs_volume.xtl_db.id
    region        = var.region
    payload_image = var.payload_image
    db_image      = var.db_image
  }
}

resource "aws_launch_template" "gamehost" {
  name_prefix   = "gamehost"
  image_id      = data.aws_ami.ec2.id
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [
      aws_security_group.www_to_ec2_nlb.id
    ]
  }
  key_name               = aws_key_pair.admin.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.host-profile.name
  }
  user_data              = base64encode(data.template_file.gamehost.rendered)

  lifecycle {
    create_before_destroy = true
  }
}