<!-- BEGIN_TF_DOCS -->
# terraform-aws-s3-bucket-kops-state

GitHub: [StratusGrid/terraform-aws-s3-bucket-kops-state](https://github.com/StratusGrid/terraform-aws-s3-bucket-kops-state)

This module creates a Bucket and related policy to be used as a logging bucket.

It configures a bucket with:
- SSE-S3 unless SSE-KMS is specified (KMS will incur an additional charge)
- Requires encrypted transit
- Optional cross account trust for using this state bucket in a centralized account with other accounts storing/retrieving state from it.
- When using cross account permissions, you will usually want to force 'bucket-owner-full-control' ACL on all objects (otherwise the bucket owner may not be able to see them). This can be done by running this command before running kops:
```
export KOPS_STATE_S3_ACL=bucket-owner-full-control
```
- Optional cross account read only option for using this state bucket in a centralized account with other accounts only retrieving state from it.
- If you wanted to have different customers/security levels share the bucket, you would need to restructure the cross account trusting policies to map accounts to specific keys for different clusters or similar, and even then I would NOT recommend doing this (since they could still list the bucket and see names of the other clusters, even if they couldn't access them).
- The read only option assumes you are using separate access credentials for S3 than you are using for infrastructure provisioning. See this thread for more details: https://github.com/kubernetes/kops/issues/353#issuecomment-446837838

## Example Usage:

```hcl
module "s3_kops_state" {
  source = "StratusGrid/s3-bucket-kops-state/aws"
  version = "1.0.3"
  name_prefix = "${var.name_prefix}"
  logging_bucket_id = "${module.s3_bucket_logging.bucket_id}"
  input_tags = "${local.common_tags}"
  sse_kms = true
  cross_account_trusted_rw_account_arns = ["arn:aws:iam::123456789:root"]
}
```
---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.key_alias_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.bucket_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.bucket_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.bucket_policy_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.bucket_policy_mapping_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.bucket_public_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.bucket_public_policy_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.bucket_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cross_account_trusted_ro_account_arns"></a> [cross\_account\_trusted\_ro\_account\_arns](#input\_cross\_account\_trusted\_ro\_account\_arns) | List of accounts to be trusted with cross account read only access to bucket for masters and nodes - NOT enough for cluster creation/changes. | `list(string)` | `[]` | no |
| <a name="input_cross_account_trusted_rw_account_arns"></a> [cross\_account\_trusted\_rw\_account\_arns](#input\_cross\_account\_trusted\_rw\_account\_arns) | List of accounts to be trusted with cross account read write access to bucket for masters and nodes - this IS enough for cluster creation/changes. | `list(string)` | `[]` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_logging_bucket_id"></a> [logging\_bucket\_id](#input\_logging\_bucket\_id) | ID of logging bucket | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to prefix on object names | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_sse_kms"></a> [sse\_kms](#input\_sse\_kms) | Boolean equivalent to determine whether kms should be used for default bucket encryption | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of bucket to be referenced in policies etc. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of bucket |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | ARN of KMS Key Alias created |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of KMS Key created |

---

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->