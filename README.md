<!-- BEGIN_TF_DOCS -->
# terraform-aws-s3-bucket-kops-state
GitHub: [StratusGrid/terraform-aws-s3-bucket-kops-state](https://github.com/StratusGrid/terraform-aws-s3-bucket-kops-state)
## Example
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
## StratusGrid Standards we assume
- All resource names and name tags shall use `_` and not `-`s
- The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
- StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)
## Repo Knowledge

This module configures a bucket with:

- SSE-S3 unless SSE-KMS is specified (KMS will incur an additional charge)
- Requires encrypted transit
- Optional cross account trust for using this state bucket in a centralized account with other accounts storing/retrieving state from it.
- When using cross account permissions, you will usually want to force 'bucket-owner-full-control' ACL on all objects (otherwise the bucket owner may not be able to see them). This can be done by running this command before running kops:

export KOPS_STATE_S3_ACL=bucket-owner-full-control

Optional cross account read only option for using this state bucket in a centralized account with other accounts only retrieving state from it.
If you wanted to have different customers/security levels share the bucket, you would need to restructure the cross account trusting policies to map accounts to specific keys for different clusters or similar, and even then I would NOT recommend doing this (since they could still list the bucket and see names of the other clusters, even if they couldn't access them).
The read only option assumes you are using separate access credentials for S3 than you are using for infrastructure provisioning. See this thread for more details: [kubernetes/kops#353 (comment)](https://github.com/kubernetes/kops/issues/353#issuecomment-446837838)

NOTE: If only using within the applied account, you can set the cross_account_trusted_rw_account_arns like so: ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]

## Documentation
This repo is self documenting via Terraform Docs, please see the note at the bottom.
### `LICENSE`
This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).
### `outputs.tf`
The StratusGrid standard for Terraform Outputs.
### `README.md`
It's this file! I'm always updated via TF Docs!
### `tags.tf`
The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.
### `variables.tf`
All variables related to this repo for all facets.
One day this should be broken up into each file, maybe maybe not.
### `versions.tf`
This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.
## Documentation of Misc Config Files
This section is supposed to outline what the misc configuration files do and what is there purpose
### `.config/.terraform-docs.yml`
This file auto generates your `README.md` file.
### `.github/workflows/pre-commit.yml`
This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.
### `examples/*`
The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.
### `.gitignore`
This is your gitignore, and contains a slew of default standards.
---
## Requirements

No requirements.
## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.key_alias_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.bucket_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.bucket_policy_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.bucket_policy_mapping_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cross_account_trusted_ro_account_arns"></a> [cross\_account\_trusted\_ro\_account\_arns](#input\_cross\_account\_trusted\_ro\_account\_arns) | List of accounts to be trusted with cross account read only access to bucket for masters and nodes - NOT enough for cluster creation/changes. | `list(string)` | `[]` | no |
| <a name="input_cross_account_trusted_rw_account_arns"></a> [cross\_account\_trusted\_rw\_account\_arns](#input\_cross\_account\_trusted\_rw\_account\_arns) | List of accounts to be trusted with cross account read write access to bucket for masters and nodes - this IS enough for cluster creation/changes. | `list(string)` | `[]` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_logging_bucket_id"></a> [logging\_bucket\_id](#input\_logging\_bucket\_id) | ID of logging bucket | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to prefix on object names | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_sse_kms"></a> [sse\_kms](#input\_sse\_kms) | Boolean to determine whether kms should be used for default bucket encryption | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of bucket to be referenced in policies etc. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of bucket |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
---
Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->