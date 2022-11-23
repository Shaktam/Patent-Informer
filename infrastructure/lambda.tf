resource "aws_lambda_function" "patent_lambda" {
  filename      = "build/patent_lambda.zip"
  function_name = "patent-lambda-dynamodb"
  role          = locals.iam_role  
  handler       = "patent-dynamodb.handler"
  timeout       = 300
  runtime       = "python3.9"
  source_code_hash = filebase64sha256("build/patent_lambda.zip")

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


resource "aws_cloudwatch_event_rule" "every_twentyfour_hours" {
    name = "every-twentyfour_hours"
    description = "Fires every twentyfour_hours"
    schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "patent_notifier_every_twentyfour_hours" {
    rule = aws_cloudwatch_event_rule.every_twentyfour_hours.name
    target_id = "patent_lambda"
    arn = aws_lambda_function.patent_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_patentname" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.patent_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_twentyfour_hours.arn
}
