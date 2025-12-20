# Brief Output: Just the list of Public IPs
output "web_nodes_ips" {
  value = aws_instance.web_nodes[*].public_ip
}

# Brief Output: Map of Team -> Bucket Name
output "team_buckets" {
  value = { for k, v in aws_s3_bucket.team_assets : k => v.bucket }
}

# Brief Output: Confirmation of DR Region
output "dr_location" {
  value = "DR Bucket is in: ${aws_s3_bucket.dr_backup.region}"
}

# Brief Output: App Server ID
output "app_server_id" {
  value = aws_instance.app_server.id
}