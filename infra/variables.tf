variable "awsRegion" {
  description = "AWS Region to spin up the infrastructure"
  default = "eu-west-1"
}

variable "awsAmis" {
  default = {
    eu-west-1 = "ami-a0a11bd3"
    us-east-1 = "ami-85c1c0ef"
    us-west-1 = "ami-582b5938"
    us-west-2 = "ami-1f836a7f"
    eu-central-1 = "ami-989a7df7"
  }
}

#
# Most probably this won't work on your environment
# Thus, simple change it the the path you have.
#
variable "publicKeyPath" {
  description = "Public key path for communicating with infrastructure"
  default = "~/.ssh/publicKeys/id_rsa.pub"
}

variable "publicKeyName" {
  description = "Public Key Name"
  default = "jo-U2FpbnNidXJ5"
}