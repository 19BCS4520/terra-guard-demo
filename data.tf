# data.tf

# EXPLANATION: Dynamically find the latest Amazon Linux 2023 AMI.
# We use a wildcard (*) so it works even if AWS updates the version number.
data "aws_ami" "latest_al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    # This pattern matches the official Amazon Linux 2023 naming convention
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}