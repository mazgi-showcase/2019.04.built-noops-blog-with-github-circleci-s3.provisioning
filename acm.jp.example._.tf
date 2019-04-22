# --------------------------------
# ACM Certificate for *.example.jp
resource "aws_acm_certificate" "certificate_jp_example_" {
  domain_name               = "${aws_route53_record.record_jp_example.fqdn}"
  subject_alternative_names = ["*.${aws_route53_record.record_jp_example.fqdn}"]
  validation_method         = "DNS"
}

# for example.jp
resource "aws_route53_record" "certificate-validation-records_jp_example" {
  name    = "${aws_acm_certificate.certificate_jp_example_.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate_jp_example_.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.zone_jp_example.zone_id}"
  records = ["${aws_acm_certificate.certificate_jp_example_.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# for *.example.jp
resource "aws_route53_record" "certificate-validation-records_jp_example_" {
  name    = "${aws_acm_certificate.certificate_jp_example_.domain_validation_options.1.resource_record_name}"
  type    = "${aws_acm_certificate.certificate_jp_example_.domain_validation_options.1.resource_record_type}"
  zone_id = "${aws_route53_zone.zone_jp_example.zone_id}"
  records = ["${aws_acm_certificate.certificate_jp_example_.domain_validation_options.1.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate-validation_jp_example_" {
  certificate_arn = "${aws_acm_certificate.certificate_jp_example_.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.certificate-validation-records_jp_example.fqdn}",
    "${aws_route53_record.certificate-validation-records_jp_example_.fqdn}",
  ]
}
