output "bucket_arn" {
  description = "ARN of bucket to be referenced in policies etc."
  value = "${aws_s3_bucket.bucket.id}"
}

output "bucket_id" {
  description = "ID of bucket"
  value = "${aws_s3_bucket.bucket.id}"
}
