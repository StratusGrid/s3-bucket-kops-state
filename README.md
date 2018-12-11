# s3-bucket-kops-state
This module configures a bucket with:
 - Server Side Encryption (Not KMS)
 - Requires encrypted transit
 - A randomly generated UID after the name

```
module "s3_kops_state" {
  source = "https://github.com/StratusGrid/s3-bucket-kops-state"
  name_prefix    = "${var.name_prefix}"
  logging_bucket_id  = "${module.s3_bucket_logging.bucket_id}"
  input_tags        = "${local.common_tags}"
}
```
