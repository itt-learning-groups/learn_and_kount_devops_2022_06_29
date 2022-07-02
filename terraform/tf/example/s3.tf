
resource "aws_s3_bucket" "notes_bucket" {
  bucket        = "${local.pref}-${var.bucket_name}"
  force_destroy = var.destroy_s3_objects
}

resource "aws_s3_bucket_acl" "notes_bucket_acl" {
  bucket = aws_s3_bucket.notes_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "notes_bucket_private_acess" {
  bucket              = aws_s3_bucket.notes_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "notes_bucket_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "AllowAdminAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${var.admin_role}"
      ]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.notes_bucket.arn,
      "${aws_s3_bucket.notes_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowNotesWriterAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.notes_writer_role.arn
      ]
    }
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      aws_s3_bucket.notes_bucket.arn,
      "${aws_s3_bucket.notes_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowNotesReaderAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.notes_reader_role.arn
      ]
    }
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      aws_s3_bucket.notes_bucket.arn,
      "${aws_s3_bucket.notes_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "notes_bucket_policy" {
  bucket = aws_s3_bucket.notes_bucket.id
  policy = data.aws_iam_policy_document.notes_bucket_policy_doc.json
  depends_on = [
    aws_iam_role.notes_reader_role,
    aws_iam_role.notes_writer_role
  ]
}
