
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_security_group" "my_server_sg" {
  name        = "my_server_sg"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.my_ip_with_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    description      = "Outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key //"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6/y3RU73Qe6JIOHyNzauJVfOn1MUjOEHxe0nvLvLRqW0EVcAZUB+JtJ8zqNODam2pI+HMgQd3W0vb41ZBfIQqHalfI5Y76sgNWatQGevJqogU56Dp7yIvtlE1Qtv5cDGT1kDderNfJFy152KfWJw81dB3n62OHwuBmxP9OWU05SlU0ZxBb7o/Qd7pwd4gixdnFrvnskvHBaLBkC609AleMg/IvEKB4ooujlQf5FlIDHC0DVe7CTV/IN4FIjnFn0uZCXkzDsTkUteFJM0U7LCG+lllYjVc2aRWwuLalu+NPe3LF29xtEeFxq0FXbAKnnmLNiq9FzJk9pg26jgYj4zUNbuhDHWpqZPwDmhjh+z5in+PS0bBDUUsbSRwN0jx6VK4s6MH1eMIvW4imNL5mYvLXMOlZyDTuaVuRYZzb5IUETrMcCi3uhqxp1PkcsCSOZkgO/0+rm0lqaWZwt9jsIvwqNv2IKsfqBUXUnMSvovZ90kc6szLLSTYwFJIQJH/tvU= USER@DESKTOP-DAE9MEL"
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

data "aws_ami" "amazon-linux-2" {
 	most_recent = true
	owners = ["amazon"]
	filter {
		name   = "owner-alias"
		values = ["amazon"]
	}
	filter {
		name   = "name"
		values = ["amzn2-ami-hvm*"]
	}
}

resource "aws_instance" "my_server" {
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  subnet_id = tolist(data.aws_subnet_ids.subnet_ids.ids)[0]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.my_server_sg.id]
  user_data              = data.template_file.user_data.rendered
  
  tags = {
    Name = var.server_name
  }
}
