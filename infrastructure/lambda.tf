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

resource "aws_lambda_event_source_mapping" "patent_table_update" {
  event_source_arn  = aws_dynamodb_table.Patent-dynamodb-table.stream_arn
  function_name     = aws_lambda_function.patent_lambda.arn
  starting_position = "LATEST"
}
