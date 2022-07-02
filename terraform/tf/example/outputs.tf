output "notes_reader_role_arn" {
  value = aws_iam_role.notes_reader_role.arn
}

output "notes_writer_role_arn" {
  value = aws_iam_role.notes_writer_role.arn
}

output "bucket_url" {
  value = aws_s3_bucket.notes_bucket.bucket_domain_name
}

output "bucket" {
  value = aws_s3_bucket.notes_bucket.bucket
}