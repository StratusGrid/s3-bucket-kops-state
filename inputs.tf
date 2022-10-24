variable "name_prefix" {
  description = "String to prefix on object names"
  type        = string
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using"
  type        = string
  default     = ""
}

variable "logging_bucket_id" {
  description = "ID of logging bucket"
  type        = string
}

variable "sse_kms" {
  description = "Boolean to determine whether kms should be used for default bucket encryption"
  default     = false
}

variable "cross_account_trusted_ro_account_arns" {
  description = "List of accounts to be trusted with cross account read only access to bucket for masters and nodes - NOT enough for cluster creation/changes."
  type        = list(string)
  default     = []
}

variable "cross_account_trusted_rw_account_arns" {
  description = "List of accounts to be trusted with cross account read write access to bucket for masters and nodes - this IS enough for cluster creation/changes."
  type        = list(string)
  default     = []
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
