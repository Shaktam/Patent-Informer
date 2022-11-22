resource "aws_lambda_function" "patent_notifier" {
  function_name = "patent_notifier_s3"
  filename       = "build/job_crawler.zip"
  role          = "arn:aws:iam::467749311079:role/LabRole"
  handler       = "patent-s3.handler"
  timeout       = 300
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.requests_layer.arn]
  source_code_hash = filebase64sha256("build/job_crawler.zip")

  environment {
    variables = {
      PATENT_TABLE_NAME = aws_dynamodb_table.Patent-dynamodb-table.name
    }
  }
}


resource "aws_lambda_layer_version" "requests_layer" {
  s3_bucket     = "job-notifier-src-bucket-21345"
  s3_key        = "requests-layer.zip"
  layer_name    = "requests-layer"

  compatible_runtimes = ["python3.9"]
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "job_crawler_every_five_minutes" {
    rule = aws_cloudwatch_event_rule.every_five_minutes.name
    target_id = "crawl-jobs"
    arn = aws_lambda_function.job_crawler.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_job_crawler" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.job_crawler.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_five_minutes.arn
}