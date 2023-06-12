variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "Name" {
  type    = string
  default = "test-vpc"

}

variable "public1_name" {
  type    = string
  default = "test-public"

}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}


variable "private_subnet_cidr" {
  type = list(string)
}

variable "instance_id" {
  type = string
}

# variable "subnet_id_lb" {
#   type = list(string)
# }

variable "availability_zones" {
  type = list(string)
}
