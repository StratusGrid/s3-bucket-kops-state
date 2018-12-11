variable "name_prefix" {
  description = "String to prefix on object names"
  type = "string"
}

variable "logging_bucket_id" {
  description = "ID of logging bucket"
  type = "string"
}

variable "sse_kms" {
  description = "Boolean to determine whether kms should be used for default bucket encryption"
  default = false
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type = "map"
  default = {}
}
