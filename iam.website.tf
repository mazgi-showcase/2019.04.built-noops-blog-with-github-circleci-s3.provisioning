# --------------------------------
# IAM users for content maintenance
resource "aws_iam_user" "website-content-maintenance-cicd-users" {
  count = "${length(var.envs)}"

  name          = "website-content-maintenance-cicd-user-${element(var.envs, count.index)}"
  force_destroy = true
}

# --------------------------------
# IAM group
data "aws_iam_policy_document" "website-content-maintenance-cicd-group-policies" {
  count = "${length(var.envs)}"

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "${element(aws_s3_bucket.website-content.*.arn, count.index)}/",
      "${element(aws_s3_bucket.website-content.*.arn, count.index)}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = [
        "192.0.2.0/24",    # Office
        "198.51.100.0/24", # VPN
        "203.0.113.0/24",  # IDC
      ]
    }
  }

  statement {
    actions = ["cloudfront:CreateInvalidation"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "website-content-maintenance-cicd-group-policies" {
  count = "${length(var.envs)}"

  name   = "website-content-maintenance-cicd-group-policy-${element(var.envs, count.index)}"
  policy = "${element(data.aws_iam_policy_document.website-content-maintenance-cicd-group-policies.*.json, count.index)}"
}

resource "aws_iam_group" "website-content-maintenance-cicd-groups" {
  count = "${length(var.envs)}"

  name = "website-content-maintenance-cicd-group-${element(var.envs, count.index)}"
}

resource "aws_iam_group_policy_attachment" "website-content-maintenance-cicd-group-attachments" {
  count = "${length(var.envs)}"

  group      = "${element(aws_iam_group.website-content-maintenance-cicd-groups.*.name, count.index)}"
  policy_arn = "${element(aws_iam_policy.website-content-maintenance-cicd-group-policies.*.arn, count.index)}"
}

resource "aws_iam_group_membership" "website-content-maintenance-cicd-group-memberships" {
  count = "${length(var.envs)}"

  name  = "website-content-maintenance-cicd-group-membership-${element(var.envs, count.index)}"
  group = "${element(aws_iam_group.website-content-maintenance-cicd-groups.*.name, count.index)}"

  users = [
    "${element(aws_iam_user.website-content-maintenance-cicd-users.*.name, count.index)}",
  ]
}
