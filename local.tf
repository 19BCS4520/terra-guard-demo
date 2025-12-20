locals {
# EXPLANATION: Generating a random suffix (e.g., "x9z1a") for unique S3 names.
  bucket_name = random_string.suffix.result
  common_tags = {
    Environment = var.env
    Project     = "Terra-Guard-Demo"
  }
}
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}