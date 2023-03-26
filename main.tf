resource "aws_s3_bucket" "main" {
  bucket        = var.site_name
  tags          = var.tags
  force_destroy = var.s3_bucket_force_destroy
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "files" {
  for_each = local.files_and_types

  bucket             = aws_s3_bucket.main.id
  key                = each.key
  content_type       = each.value
  source             = "${local.files_root}/${each.key}"
  etag               = filemd5("${local.files_root}/${each.key}")
  acl                = "public-read"
  bucket_key_enabled = false
}