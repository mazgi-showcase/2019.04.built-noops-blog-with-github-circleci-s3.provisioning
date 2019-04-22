# --------------------------------
# Route 53 DNS Zone: example.com
resource "aws_route53_zone" "zone_com_example" {
  name = "example.com"
}

# --------------------------------
# Route 53 DNS Record: example.com
resource "aws_route53_record" "record_com_example" {
  zone_id = "${aws_route53_zone.zone_com_example.zone_id}"
  name    = "example.com"
  type    = "A"
  ttl     = "300"

  records = [
    "192.0.2.1",
  ]
}

# --------------------------------
# Outputs
output "example.com::zone_id" {
  value = "${aws_route53_zone.zone_com_example.zone_id}"
}

output "example.com::name_servers" {
  value = "${aws_route53_zone.zone_com_example.name_servers}"
}
