# --------------------------------
# S3 bucket policies for content
data "aws_iam_policy_document" "website-s3-policy" {
  count = "${length(var.envs)}"

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${element(aws_s3_bucket.website-content.*.arn, count.index)}/*",
    ]

    principals {
      type = "AWS"

      identifiers = ["${element(aws_cloudfront_origin_access_identity.website-origin_access_identities.*.iam_arn, count.index)}"]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${element(aws_s3_bucket.website-content.*.arn, count.index)}",
    ]

    principals {
      type = "AWS"

      identifiers = ["${element(aws_cloudfront_origin_access_identity.website-origin_access_identities.*.iam_arn, count.index)}"]
    }
  }
}

resource "aws_s3_bucket_policy" "website-s3-policy" {
  count = "${length(var.envs)}"

  bucket = "${element(aws_s3_bucket.website-content.*.id, count.index)}"
  policy = "${element(data.aws_iam_policy_document.website-s3-policy.*.json, count.index)}"
}

# --------------------------------
# S3 buckets for content
resource "aws_s3_bucket" "website-content" {
  count = "${length(var.envs)}"

  bucket = "${element(var.envs, count.index)}-${var.service_name}-content"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags {}

  force_destroy = true
}

# --------------------------------
# S3 buckets for logging
resource "aws_s3_bucket" "website-log" {
  count = "${length(var.envs)}"

  bucket = "${element(var.envs, count.index)}-${var.service_name}-log"

  tags {}

  force_destroy = true
}

# --------------------------------
# Outputs
output "website-content::s3-bucket::arn" {
  value = ["${aws_s3_bucket.website-content.*.arn}"]
}
