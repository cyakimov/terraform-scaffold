resource "aws_cloudtrail" "auditlog" {
  name = "${var.name_prefix}auditlog-trail"
  s3_bucket_name = "${aws_s3_bucket.logs.id}"
  s3_key_prefix = "cloudtrail"
  include_global_service_events = true
  enable_logging = true
}
