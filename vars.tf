variable "default_tags" {
  type = map(string)
  default = {
    "env" = "RobT"
  }
  description = "Robs Variables"
}

variable "public_subnet_count" {
  type        = number
  description = "Public Subnet Count"
  default     = 2
}
