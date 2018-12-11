# s3-bucket-kops-state
This module configures a bucket with:
 - SSE-S3 unless SSE-KMS is specified (KMS will incur an additional charge) 
 - Requires encrypted transit
 - A randomly generated UID after the name
 
 ## Example Usage:
```
module "s3_kops_state" {
  source = "StratusGrid/s3-bucket-kops-state/aws"
  version = "1.0.1"
  name_prefix = "${var.name_prefix}"
  logging_bucket_id = "${module.s3_bucket_logging.bucket_id}"
  input_tags = "${local.common_tags}"
  sse_kms = true
}
```
