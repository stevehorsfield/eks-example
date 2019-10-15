resource "aws_s3_bucket_object" "update-auto-reboot-install-script" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/update-auto-reboot/update-auto-reboot-install"
  source = "content/update-auto-reboot/install"
  acl    = "private"
  etag   = "${md5(file("content/update-auto-reboot/install"))}"
}

resource "aws_s3_bucket_object" "update-auto-reboot-command-file" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/update-auto-reboot/reboot-if-needed-after-updates"
  source = "content/update-auto-reboot/reboot-if-needed-after-updates"
  acl    = "private"
  etag   = "${md5(file("content/update-auto-reboot/reboot-if-needed-after-updates"))}"
}

resource "aws_s3_bucket_object" "update-auto-reboot-service-file" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/update-auto-reboot/reboot-if-needed-after-updates.service"
  source = "content/update-auto-reboot/reboot-if-needed-after-updates.service"
  acl    = "private"
  etag   = "${md5(file("content/update-auto-reboot/reboot-if-needed-after-updates.service"))}"
}