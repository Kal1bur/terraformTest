variable "default_tags" {
  type = map(string)
  default = {
    "env" = "RobT"
  }
  description = "Robs Variables Description"
}

variable "public_subnet_count" {
  type        = number
  description = "Public Subnet Count"
  default     = 2
}
