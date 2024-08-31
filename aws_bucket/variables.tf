## ----- general configuration -------------------------------------------------

variable "bucket_name" {
  description = "Name of the bucket."
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the bucket name."
  type        = string
  default     = "tegridy"
}

variable "user_name" {
  description = "If provided no additional user will be created."
  type        = string
  default     = ""
}
