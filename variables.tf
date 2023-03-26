variable "site_name" {
  type        = string
  description = "Lower case name for the site"

  validation {
    condition     = can(regex("^[a-z0-9\\-_]{1,64}$", var.site_name))
    error_message = "Must be lower-case characters (26 letter english alphabet), with numbers, hyphens and underscores."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Some meaningful tags to add to resources created by this configuration"
}

variable "s3_bucket_force_destroy" {
  type        = bool
  default     = true
  description = "If true will let the bucket be deleted even with the contents, otherwise should be set to false to protect it"
}