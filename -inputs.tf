variable "name_prefix" {
  description = "String to prefix on object names"
  type = "string"
}

variable "logging_bucket_id" {
  description = "ID of logging bucket"
  type = "string"
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type = "map"
  default = {}
}
