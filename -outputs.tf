output "bucket_arn" {
  description = "ARN of bucket to be referenced in policies etc."
  value = "${join(",", concat(aws_s3_bucket.bucket_kms.*.arn, aws_s3_bucket.bucket.*.arn))}"
}

output "bucket_id" {
  description = "ID of bucket"
  value = "${join(",", concat(aws_s3_bucket.bucket_kms.*.id, aws_s3_bucket.bucket.*.id))}"
}

output "kms_key_alias_arn" {
  value = "${aws_kms_alias.key_alias_kms.0.arn}"
}

output "kms_key_arn" {
  value = "${aws_kms_key.key_kms.0.arn}"
}
