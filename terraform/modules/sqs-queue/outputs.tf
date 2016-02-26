output "queue_arn" {
  value = "${aws_sqs_queue.queue.arn}"
}

output "admin_policy" {
  value = <<EOF
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action": [
        "sqs:CreateQueue",
        "sqs:ListQueues"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":"sqs:*",
      "Resource":"${aws_sqs_queue.queue.arn}"
    }
  ]
}
EOF

}

output "send_policy" {
  value = <<EOF
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action": [
        "sqs:ListQueues"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":"sqs:SendMessage",
      "Resource":"${aws_sqs_queue.queue.arn}"
    }
   ]
}
EOF

}

output "receive_policy" {
  value = <<EOF
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action": [
        "sqs:ListQueues"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":"sqs:ReceiveMessage",
      "Resource":"${aws_sqs_queue.queue.arn}"
    }
   ]
}
EOF

}
