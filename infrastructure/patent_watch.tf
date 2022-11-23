resource "aws_lambda_function" "patent_notifier" {
  function_name = "patent_notifier_s3"
  filename       = "x.zip"
  role          = "arn:aws:iam::467749311079:role/LabRole"
  handler       = "patent-s3.handler"
  timeout       = 300
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.requests_layer.arn]
  source_code_hash = filebase64sha256("patent_notifier.zip")

  environment {
    variables = {
      PATENT_TABLE_NAME = aws_dynamodb_table.Patent-dynamodb-table.name
    }
  }
}


resource "aws_lambda_layer_version" "requests_layer" {
  s3_bucket     = "patent-notifier-bucket"
  s3_key        = "requests-layer.zip"
  layer_name    = "requests-layer"

  compatible_runtimes = ["python3.9"]
}

resource "aws_cloudwatch_event_rule" "every_twentyfour_hours" {
    name = "every-twentyfour_hours"
    description = "Fires every twentyfour_hours"
    schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "patent_notifier_every_twentyfour_hours" {
    rule = aws_cloudwatch_event_rule.every_twentyfour_hours.name
    target_id = "patent_notify"
    arn = aws_lambda_function.patent_notifier.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_patentname" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.patent_notifier.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_twentyfour_hours.arn
}
