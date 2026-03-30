output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${module.frontend.cloudfront_domain_name}"
}
