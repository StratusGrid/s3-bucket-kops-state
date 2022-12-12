resource "aws_kms_key" "key_kms" {
  count = var.sse_kms

  description         = "Key for ${var.name_prefix}-kops-state${var.name_suffix}"
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_alias" "key_alias_kms" {
  count = var.sse_kms

  name          = "alias/${var.name_prefix}-kops-state${var.name_suffix}"
  target_key_id = aws_kms_key.key_kms[0].key_id
}

resource "aws_s3_bucket" "bucket_kms" {
  count = var.sse_kms

  bucket = "${var.name_prefix}-kops-state${var.name_suffix}"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "bucket_kms" {
  count = var.sse_kms

  bucket = aws_s3_bucket.bucket_kms[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_kms" {
  count = var.sse_kms

  bucket = aws_s3_bucket.bucket_kms[0].id

  target_bucket = var.logging_bucket_id
  target_prefix = "s3/${var.name_prefix}-kops-state${var.name_suffix}/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_kms" {
  count = var.sse_kms

  bucket = aws_s3_bucket.bucket_kms[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key_kms[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy_kms" {
  count = var.sse_kms

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
      aws_s3_bucket.bucket_kms[0].arn
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
      "${aws_s3_bucket.bucket_kms[0].arn}/*"
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
      "${aws_s3_bucket.bucket_kms[0].arn}/*"
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
      aws_s3_bucket.bucket_kms[0].arn,
      "${aws_s3_bucket.bucket_kms[0].arn}/*"
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_mapping_kms" {
  count = var.sse_kms

  bucket = aws_s3_bucket.bucket_kms[0].id
  policy = data.aws_iam_policy_document.bucket_policy_kms[0].json
}

resource "aws_s3_bucket_public_access_block" "bucket_public_policy_kms" {
  count = var.sse_kms

  bucket                  = aws_s3_bucket.bucket_kms[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
