# s3-bucket-kops-state
This module configures a bucket with:
 - Server Side Encryption (Not KMS)
 - Requires encrypted transit
 - A randomly generated UID after the name
 
 ## Example Usage:
```
module "s3_kops_state" {
  source = "StratusGrid/s3-bucket-kops-state/aws"
  version = "1.0.0"
  name_prefix = "${var.name_prefix}"
  logging_bucket_id = "${module.s3_bucket_logging.bucket_id}"
  input_tags = "${local.common_tags}"
}
```
