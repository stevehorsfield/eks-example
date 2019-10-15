resource "aws_s3_bucket" "system-configuration" {
  bucket = "${var.environment}-system-configuration-${data.aws_region.this.name}"
  acl    = "private"

  tags {
    Name        = "${var.environment}-system-configuration"
    Environment = "${var.environment}"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "system-configuration" {
  bucket = "${aws_s3_bucket.system-configuration.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}