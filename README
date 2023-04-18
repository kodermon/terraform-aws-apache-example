this is a beginner learning terraform module

not to be used.

```hcl
terraform {

}

provider "aws" {
  region = "us-east-1"
}

module "apache" {
  source = ".//terraform-aws-apache-example"
  vpc_id          = "vpc-00000000000"
  my_ip_with_cidr = "IP_ADDRESS/32"
  public_key      = "ssh-rsa AAAAB..."
  instance_type   = "t2.micro"
  server_name     = "Apache Server Example"
}

output "public_ip" {
  value = module.apache.public_ip
}
```
