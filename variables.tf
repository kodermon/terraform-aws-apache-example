variable "vpc_id" {
  type = string
}

variable "my_ip_with_cidr" {
  type = string
  description = "provide your ip e.g 102.89.22.124/32"
}

variable "public_key" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_name" {
  type = string
  default = "Apache Server Example"
}