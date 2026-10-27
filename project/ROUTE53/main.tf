resource "aws_route53_zone" "this" {
  name = var.domain_name
}

# Fetch Traefik LoadBalancer dynamically
data "aws_lb" "traefik" {
  name = "a9bd0fecb03a74fbeac280126d1de7ec"
}

# Define subdomains once
locals {
  subdomains = [
    "vault",
    "argocd",
    "dev",
    "prometheus",
    "grafana"
  ]
}

# Create records dynamically
resource "aws_route53_record" "records" {
  for_each = toset(local.subdomains)

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.traefik.dns_name
    zone_id                = data.aws_lb.traefik.zone_id
    evaluate_target_health = true
  }
}

