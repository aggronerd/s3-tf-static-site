output "website_url" {
  value = "https://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}