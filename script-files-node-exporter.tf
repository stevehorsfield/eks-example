resource "aws_s3_bucket_object" "node-exporter-install-script" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/node-exporter/node-exporter-install"
  source = "content/node-exporter/node-exporter-install"
  acl    = "private"
  etag   = "${md5(file("content/node-exporter/node-exporter-install"))}"
}

resource "aws_s3_bucket_object" "node-exporter-env-file" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/node-exporter/node-exporter.env"
  source = "content/node-exporter/node-exporter.env"
  acl    = "private"
  etag   = "${md5(file("content/node-exporter/node-exporter.env"))}"
}

resource "aws_s3_bucket_object" "node-exporter-service-file" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/node-exporter/node-exporter.service"
  source = "content/node-exporter/node-exporter.service"
  acl    = "private"
  etag   = "${md5(file("content/node-exporter/node-exporter.service"))}"
}