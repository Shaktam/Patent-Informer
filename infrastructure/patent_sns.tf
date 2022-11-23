resource "aws_sns_topic" "patent_email" {
  name = "Patent-sns-Notification"
}

resource "aws_sns_topic_subscription" "patent_update_notification" {
  topic_arn = aws_sns_topic.patent_email.arn
  protocol  = "email"
  endpoint  = "cuteshakti1493@gmail.com"
}
