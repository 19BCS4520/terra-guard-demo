resource "aws_instance" "web_nodes" {
# 'count' loops 2 times. Creates indices 0 and 1.
  count = 2
  ami   = data.aws_ami.latest_al2.id
  instance_type = var.instance_type

  # EXPLANATION: We use 'count.index' to give unique names: web-node-1, web-node-2
  tags = merge(local.common_tags, {
    Name   = "web-node-${count.index + 1}"
    Status = "Fresh"
  })

 lifecycle {
    # EXPLANATION: 'ignore_changes'
    # If AWS AutoScaling or a human changes the 'Status' tag later, 
    # Terraform will IGNORE it and NOT try to fix it. Good for drift management.
    ignore_changes = [tags["Status"]]
  }

}

# ==============================================================================
# 2. FOR_EACH - Creating Unique Resources
# =======================================================
resource "aws_s3_bucket" "team_assets" {
  for_each = var.team_settings

  bucket = "team-assets-${each.key}-${local.bucket_name}"
  tags   = merge(local.common_tags, {
    Name   = "team-assets-${each.key}"
    Status = "Fresh"
  })
}


# 3. PROVIDER ALIAS - Multi-Region
# ==============================================================================
resource "aws_s3_bucket" "dr_backup" {
  # EXPLANATION: 'provider' forces this resource into the 'us-west-1' region
  # defined in provider.tf with the alias "dr_west".
  provider = aws.dr_west

  bucket = "dr-critical-backup-${local.bucket_name}"
}
# 4. CREATE_BEFORE_DESTROY - Zero Downtime
# ==================================================
resource "aws_security_group" "web_sg" {
  name = "web-sg-v1"
  description = "Security group for web servers"
  lifecycle {
    create_before_destroy =true
  }
}

# 5. DEPENDS_ON & REPLACE_TRIGGERED_BY - Dependencies
# ==============================================================================
# Step A: Create Config File locally
resource "local_file" "app_config" {
  content  = "version=1.0"
  filename = "${path.module}/app.conf"
}

# Step B: Create Server dependent on that config
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.latest_al2.id
  instance_type = "t2.micro"

  # EXPLANATION: 'depends_on'
  # Explicitly tells Terraform: "Do not start creating this instance until
  # the 'web_sg' is completely finished." (Solves hidden race conditions).
  depends_on = [aws_security_group.web_sg]

  tags = { Name = "App-Server-Immutable" }

  lifecycle {
    # EXPLANATION: 'replace_triggered_by'
    # Watch the 'local_file.app_config' resource.
    # If the file content changes, DESTROY this instance and create a NEW one.
    replace_triggered_by = [local_file.app_config]
  }
}
resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliant-data-${local.bucket_name}"

  lifecycle {
    # EXPLANATION: 'precondition' (Before Apply)
    # Checks if 'var.env' is safe. If not, it stops execution immediately.
    precondition {
      condition     = var.env != "dev"
      error_message = "Stop! Production buckets cannot be created in DEV mode."
    }

    # EXPLANATION: 'postcondition' (After Apply)
    # Checks the resource AFTER creation to ensure it landed in the right region.
    postcondition {
      condition     = self.region == "us-east-1"
      error_message = "Compliance Fail! Bucket created in wrong region."
    }
  }
}