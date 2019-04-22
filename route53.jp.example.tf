# --------------------------------
# Route 53 DNS Zone: example.jp
resource "aws_route53_zone" "zone_jp_example" {
  name = "example.jp"
}

# --------------------------------
# Route 53 DNS Record: example.jp
resource "aws_route53_record" "record_jp_example" {
  zone_id = "${aws_route53_zone.zone_jp_example.zone_id}"
  name    = "example.jp"
  type    = "A"
  ttl     = "300"

  records = [
    "192.0.2.1",
  ]
}

# --------------------------------
# Outputs
output "example.jp::zone_id" {
  value = "${aws_route53_zone.zone_jp_example.zone_id}"
}

output "example.jp::name_servers" {
  value = "${aws_route53_zone.zone_jp_example.name_servers}"
}
