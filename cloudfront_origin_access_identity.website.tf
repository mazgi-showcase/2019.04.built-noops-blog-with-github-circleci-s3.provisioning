# --------------------------------
# Origin Access Identities for S3 buckets and CloudFront
resource "aws_cloudfront_origin_access_identity" "website-origin_access_identities" {
  count = "${length(var.envs)}"
}

# --------------------------------
# Outputs
output "website-content::origin_access_identity::id" {
  value = ["${aws_cloudfront_origin_access_identity.website-origin_access_identities.*.id}"]
}
