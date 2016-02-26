resource "aws_sqs_queue" "queue" {
  name = "${var.name_prefix}${var.name}"
}
