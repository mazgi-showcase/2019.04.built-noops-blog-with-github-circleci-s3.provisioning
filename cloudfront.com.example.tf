# --------------------------------
# CloudFront: example.com
resource "aws_cloudfront_distribution" "distribution_com_example" {
  count = "${length(var.envs)}"

  # WAF:
  # Enabled if environments are:
  #   - `external` => disabled (blank)
  #   - `internal` or `review` => enabled
  web_acl_id = "${element(var.envs, count.index) == var.default_env_name ? "" : aws_waf_web_acl.website-waf-web-acl.id}"

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  origin {
    domain_name = "${element(aws_s3_bucket.website-content.*.bucket_regional_domain_name, count.index)}"
    origin_id   = "${element(var.envs, count.index)}-${var.service_name}-origin_id"

    s3_origin_config {
      origin_access_identity = "${element(aws_cloudfront_origin_access_identity.website-origin_access_identities.*.cloudfront_access_identity_path, count.index)}"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${element(aws_s3_bucket.website-log.*.bucket_domain_name, count.index)}"
    prefix          = "${element(var.envs, count.index)}-${var.service_name}/"
  }

  aliases = [
    "${element(var.envs, count.index) == var.default_env_name ? "" : format("%s.", element(var.envs, count.index))}example.com",
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${element(var.envs, count.index)}-${var.service_name}-origin_id"
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association = [
      {
        event_type = "viewer-request"
        lambda_arn = "${aws_lambda_function.website-lambda-redirect-to-index-document.qualified_arn}"
      },
    ]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate_com_example_.arn}"
    ssl_support_method  = "sni-only"
  }

  tags = {}
}

# --------------------------------
# Route 53 record: example.com
resource "aws_route53_record" "records_com_example_" {
  count = "${length(var.envs)}"

  zone_id = "${aws_route53_zone.zone_com_example.zone_id}"

  # ToDo: remove `temporary.`
  name = "${element(var.envs, count.index) == var.default_env_name ? "temporary." : format("%s.", element(var.envs, count.index))}example.com"
  type = "A"

  alias {
    name                   = "${element(aws_cloudfront_distribution.distribution_com_example.*.domain_name, count.index)}"
    zone_id                = "${element(aws_cloudfront_distribution.distribution_com_example.*.hosted_zone_id, count.index)}"
    evaluate_target_health = false
  }
}

# --------------------------------
# Outputs
output "website-content::distribution_com_example::domain_names" {
  value = ["${aws_cloudfront_distribution.distribution_com_example.*.domain_name}"]
}

output "website-content::records_com_example_::names" {
  value = ["${aws_route53_record.records_com_example_.*.name}"]
}
