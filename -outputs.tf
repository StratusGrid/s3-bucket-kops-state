output "bucket_arn_kms" {
  description = "ARN of bucket to be referenced in policies etc."
  count = "${var.sse_kms}"
  value = "${join(",", aws_s3_bucket.bucket_kms.*.arn)}"
}

output "bucket_id_kms" {
  description = "ID of bucket"
  count = "${var.sse_kms}"
  value = "${join(",", aws_s3_bucket.bucket_kms.*.id)}"
}

output "bucket_arn" {
  description = "ARN of bucket to be referenced in policies etc."
  count = "${1 - var.sse_kms}"
  value = "${join(",", aws_s3_bucket.bucket.*.arn)}"
}

output "bucket_id" {
  description = "ID of bucket"
  count = "${1 - var.sse_kms}"
  value = "${join(",", aws_s3_bucket.bucket.*.id)}"
}
