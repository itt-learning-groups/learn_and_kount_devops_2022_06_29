# Reader policy
data "aws_iam_policy_document" "notes_reader_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "S3ReaderBucketActions"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucketVersions"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
  statement {
    sid    = "S3ReaderObjectActions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::*/*"
    ]
  }
}

resource "aws_iam_policy" "notes_reader_policy" {
  name        = "${local.pref}-notes-reader-policy"
  policy      = data.aws_iam_policy_document.notes_reader_policy_doc.json
  description = "policy defining read only s3 actions"
}

# Reader role
data "aws_iam_policy_document" "notes_reader_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "TrustPolicy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "notes_reader_role" {
  name               = "${local.pref}-notes-reader-role"
  assume_role_policy = data.aws_iam_policy_document.notes_reader_role_policy_doc.json
  managed_policy_arns = [
    aws_iam_policy.notes_reader_policy.arn
  ]
}

# Writer policy
data "aws_iam_policy_document" "notes_writer_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "S3WriterObjectActions"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::*/*"
    ]
  }
}

resource "aws_iam_policy" "notes_writer_policy" {
  name        = "${local.pref}-notes-writer-policy"
  policy      = data.aws_iam_policy_document.notes_writer_policy_doc.json
  description = "policy defining read only s3 actions"
}

# Writer role
data "aws_iam_policy_document" "notes_writer_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "TrustPolicy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "notes_writer_role" {
  name               = "${local.pref}-notes-writer-role"
  assume_role_policy = data.aws_iam_policy_document.notes_writer_role_policy_doc.json
  managed_policy_arns = [
    aws_iam_policy.notes_writer_policy.arn,
    aws_iam_policy.notes_reader_policy.arn
  ]
}

# Group assume role policies
data "aws_iam_policy_document" "reader_group_assume_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "PolicyAssumeReaderRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.notes_reader_role.arn
    ]
  }
}

resource "aws_iam_policy" "reader_group_assume_role_policy" {
  name        = "${local.pref}-reader-group-assume-role-policy"
  policy      = data.aws_iam_policy_document.reader_group_assume_role_policy_doc.json
  description = "policy allowing assume reader role"
}

data "aws_iam_policy_document" "writer_group_assume_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "PolicyAssumeWriterRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.notes_writer_role.arn
    ]
  }
}

resource "aws_iam_policy" "writer_group_assume_role_policy" {
  name        = "${local.pref}-writer-group-assume-role-policy"
  policy      = data.aws_iam_policy_document.writer_group_assume_role_policy_doc.json
  description = "policy allowing assume writer role"
}

# ATTACH POLICIES TO ADMIN GROUP
resource "aws_iam_group_policy_attachment" "reader_admin_group_policy_attachment" {
  group      = var.admin_group_name
  policy_arn = aws_iam_policy.reader_group_assume_role_policy.arn
}

resource "aws_iam_group_policy_attachment" "writer_admin_group_policy_attachment" {
  group      = var.admin_group_name
  policy_arn = aws_iam_policy.writer_group_assume_role_policy.arn
}
