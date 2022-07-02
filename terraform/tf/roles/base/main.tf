terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.1"
}

provider "aws" {
  region = "us-west-2"
}

locals {
  pref = "tf-iam-example"
}

# Base user and policy

resource "aws_iam_user" "base_user" {
  name = "${local.pref}-base-user"
}

resource "aws_iam_user_login_profile" "base_user_login_profile" {
  user = aws_iam_user.base_user.name
}

resource "aws_iam_access_key" "base_user_cli_access" {
  user = aws_iam_user.base_user.name
}

data "aws_iam_policy_document" "base_user_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBaseAssumeRole"
    effect = "Allow"
    actions = [
      "iam:ListRoles",
      "sts:AssumeRole"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "base_user_policy" {
  name   = "${local.pref}-base-user-policy"
  user   = aws_iam_user.base_user.name
  policy = data.aws_iam_policy_document.base_user_policy_doc.json
}

# s3 infra creating role and policies

data "aws_iam_policy_document" "s3_infra_trust_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "TrustPolicy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::111246861909:user/${aws_iam_user.base_user.name}"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "s3_infra_role" {
  name               = "${local.pref}-s3-infra-role"
  assume_role_policy = data.aws_iam_policy_document.s3_infra_trust_role_policy_doc.json
}

data "aws_iam_policy_document" "s3_infra_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "AllowS3AdminActions"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowIAMAdminActions"
    effect = "Allow"
    actions = [
      "iam:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3_infra_role_policy" {
  name   = "${local.pref}-admin-role-policy"
  policy = data.aws_iam_policy_document.s3_infra_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "s3_infra_role_policy_attachment" {
  role       = aws_iam_role.s3_infra_role.name
  policy_arn = aws_iam_policy.s3_infra_role_policy.arn
}

# Admin role

data "aws_iam_policy_document" "admin_trust_role_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "TrustPolicy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::111246861909:root"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "admin_role" {
  name               = "${local.pref}-admin-role"
  assume_role_policy = data.aws_iam_policy_document.admin_trust_role_policy_doc.json
}

data "aws_iam_policy" "admin_role_policy" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "admin_role_policy_attachment" {
  role       = aws_iam_role.admin_role.name
  policy_arn = data.aws_iam_policy.admin_role_policy.arn
}

# Outputs

output "base_user_name" {
  value = aws_iam_user.base_user.name
}
output "base_user_id" {
  value = aws_iam_user.base_user.id
}

output "s3_infra_role_arn" {
  value = aws_iam_role.s3_infra_role.arn
}

output "admin_role_arn" {
  value = aws_iam_role.admin_role.arn
}

output "base_user_password" {
  value     = aws_iam_user_login_profile.base_user_login_profile.password
  sensitive = true
}

output "acc_key_id" {
  value     = aws_iam_access_key.base_user_cli_access.id
  sensitive = false
}

output "sec_acc_key" {
  value     = aws_iam_access_key.base_user_cli_access.secret
  sensitive = true
}








