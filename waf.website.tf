# --------------------------------
# Allowd IP Addresses for Internal/Review
resource "aws_waf_ipset" "website-waf-allowed-ipset" {
  name = "website-waf-allowed-ipset"

  # Office
  ip_set_descriptors {
    type  = "IPV4"
    value = "192.0.2.0/24"
  }

  # VPN
  ip_set_descriptors {
    type  = "IPV4"
    value = "198.51.100.0/24"
  }

  # IDC
  ip_set_descriptors {
    type  = "IPV4"
    value = "203.0.113.0/24"
  }
}

resource "aws_waf_rule" "website-waf-rule" {
  depends_on = [
    "aws_waf_ipset.website-waf-allowed-ipset",
  ]

  name        = "website-waf-rule"
  metric_name = "websiteWafRule"

  predicates {
    data_id = "${aws_waf_ipset.website-waf-allowed-ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "website-waf-web-acl" {
  depends_on = [
    "aws_waf_rule.website-waf-rule",
  ]

  name        = "website-waf-web-acl"
  metric_name = "websiteWafWebAcl"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_waf_rule.website-waf-rule.id}"
    type     = "REGULAR"
  }
}
