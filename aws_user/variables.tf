## ----- general configuration -------------------------------------------------

variable "user_name" {
  description = "Name of the user."
  type        = string
}

variable "user_prefix" {
  description = "Prefix for the user name."
  type        = string
  default     = ""
}

variable "path" {
  description = "Path to create user."
  type        = string
  default     = "/"
}

variable "aux_policies" {
  description = "Additional IAM policies."
  type        = list(string)
  default     = []
}
