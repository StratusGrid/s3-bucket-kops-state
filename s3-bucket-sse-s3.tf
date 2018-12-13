resource "aws_s3_bucket" "bucket" {
  count = "${1 - var.sse_kms}"

  bucket = "${var.name_prefix}-kops-state-${random_string.unique_bucket_name.result}"

  versioning {
    enabled = true
  }
  
  lifecycle {
    prevent_destroy = true
  }

  logging {
    target_bucket = "${var.logging_bucket_id}"
    target_prefix = "${var.name_prefix}-kops-state-${random_string.unique_bucket_name.result}/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = "${var.input_tags}"
}

data "aws_iam_policy_document" "bucket_policy" {
  count = "${1 - var.sse_kms}"

  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    effect    = "Allow"
    principals {
      identifiers = "${var.cross_account_trusted_account_arns}"
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}"
    ]
    sid       = "CrossAccountTrustingRoot"
  },
  statement {
    actions   = [
      "s3:Get*"
    ]
    effect    = "Allow"
    principals {
      identifiers = "${var.cross_account_trusted_account_arns}"
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    sid       = "CrossAccountTrustingKeys"
  },
  statement {
    actions   = [
      "s3:*"
    ]
    condition {
      test      = "Bool"
      values    = [
        "false"
      ]
      variable  = "aws:SecureTransport"
    }
    effect    = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    sid       = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_mapping" {
  count = "${1 - var.sse_kms}"

  bucket = "${aws_s3_bucket.bucket.id}"
  policy = "${data.aws_iam_policy_document.bucket_policy.json}"
}
