resource "aws_lambda_function" "patent_lambda" {
  filename      = "patent_informer.zip"
  function_name = "patent-notifier-dynamodb"
  role          = "arn:aws:iam::467749311079:role/LabRole"
  handler       = "patent-dynamodb.handler"
  timeout       = 300
  runtime       = "python3.9"
  source_code_hash = filebase64sha256("x.zip")

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.patent_email.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "Patent_table_update" {
  event_source_arn  = aws_dynamodb_table.Patent-dynamodb-table.stream_arn
  function_name     = aws_lambda_function.patent_lambda.arn
  starting_position = "LATEST"
}

resource "aws_sns_topic" "patent_email" {
  name = "Patent-sns-Notification"
}

resource "aws_sns_topic_subscription" "patent_update_notification" {
  topic_arn = aws_sns_topic.patent_email.arn
  protocol  = "email"
  endpoint  = "cuteshakti1493@gmail.com"
}