resource "aws_s3_bucket" "bucket" {
  count = 1 - var.sse_kms

  bucket = "${var.name_prefix}-kops-state${var.name_suffix}"

  lifecycle {
    prevent_destroy = true
  }

  tags = var.input_tags
}

resource "aws_s3_bucket_versioning" "bucket" {
  count = 1 - var.sse_kms

  bucket = aws_s3_bucket.bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  count = 1 - var.sse_kms

  bucket = aws_s3_bucket.bucket[0].id

  target_bucket = var.logging_bucket_id
  target_prefix = "s3/${var.name_prefix}-kops-state${var.name_suffix}/"
}

#tfsec:ignore:aws-s3-encryption-customer-key -- Ignores the warning to use kms key as this particular bucket is supposed to be encrypted with S3 AES key
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  count = 1 - var.sse_kms

  bucket = aws_s3_bucket.bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  count = 1 - var.sse_kms

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    effect = "Allow"
    principals {
      identifiers = (concat(var.cross_account_trusted_ro_account_arns, var.cross_account_trusted_rw_account_arns))
      type        = "AWS"
    }
    resources = [
      aws_s3_bucket.bucket[0].arn
    ]
    sid = "CrossAccountTrustingRoot"
  }

  statement {
    actions = [
      "s3:Get*"
    ]
    effect = "Allow"
    principals {
      identifiers = (concat(var.cross_account_trusted_ro_account_arns, var.cross_account_trusted_rw_account_arns))
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.bucket[0].arn}/*"
    ]
    sid = "CrossAccountTrustingReadKeys"
  }

  statement {
    actions = [
      "s3:Put*"
    ]
    effect = "Allow"
    principals {
      identifiers = var.cross_account_trusted_rw_account_arns
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.bucket[0].arn}/*"
    ]
    sid = "CrossAccountTrustingWriteKeys"
  }

  statement {
    actions = [
      "s3:*"
    ]
    condition {
      test = "Bool"
      values = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.bucket[0].arn,
      "${aws_s3_bucket.bucket[0].arn}/*"
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_mapping" {
  count = 1 - var.sse_kms

  bucket = aws_s3_bucket.bucket[0].id
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

resource "aws_s3_bucket_public_access_block" "bucket_public_policy" {
  count = 1 - var.sse_kms

  bucket                  = aws_s3_bucket.bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
