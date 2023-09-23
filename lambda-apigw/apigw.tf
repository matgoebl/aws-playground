resource "aws_apigatewayv2_api" "apigw" {
  name          = "playground_lambda_apigw"
  protocol_type = "HTTP"
}


resource "aws_cloudwatch_log_group" "apigw_log_group" {
  name              = "/aws/apigw/${var.lambda_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_apigatewayv2_stage" "apigw_test" {
  api_id = aws_apigatewayv2_api.apigw.id

  name        = "playground_lambda_apigw_test"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}


resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.apigw.id

  integration_uri    = aws_lambda_function.test_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "apigw_route" {
  api_id = aws_apigatewayv2_api.apigw.id

  route_key = "POST /test"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}
