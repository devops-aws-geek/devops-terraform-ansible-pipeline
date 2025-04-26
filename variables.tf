variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}