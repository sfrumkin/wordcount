resource "aws_apigatewayv2_api" "apigw" {
  name          = "serverless_gw"
  protocol_type = "HTTP"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-serverless_gw"
    }
  )
}



resource "aws_apigatewayv2_authorizer" "apigw_auth" {
  api_id           = aws_apigatewayv2_api.apigw.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "lambda-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.wordcount_user_pool_client.id]
    issuer   = "https://${aws_cognito_user_pool.wordcount_user_pool.endpoint}"
  }
}

resource "aws_apigatewayv2_stage" "apigw" {
  api_id = aws_apigatewayv2_api.apigw.id

  name        = "serverless_gw_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

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
  tags = local.common_tags
}

#########################################################
################ Signup API GW Integration ##############
#########################################################

resource "aws_apigatewayv2_integration" "signup" {
  api_id = aws_apigatewayv2_api.apigw.id

  integration_uri    = aws_lambda_function.signup_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

}

resource "aws_apigatewayv2_route" "signup" {
  api_id = aws_apigatewayv2_api.apigw.id

  route_key = "POST /signup"
  target    = "integrations/${aws_apigatewayv2_integration.signup.id}"

}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.apigw.name}"

  retention_in_days = 30

  tags = local.common_tags
}


resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}


#########################################################
################ Signin API GW Integration ##############
#########################################################

resource "aws_apigatewayv2_integration" "signin" {
  api_id = aws_apigatewayv2_api.apigw.id

  integration_uri    = aws_lambda_function.signin_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

}

resource "aws_apigatewayv2_route" "signin" {
  api_id = aws_apigatewayv2_api.apigw.id

  route_key = "POST /signin"
  target    = "integrations/${aws_apigatewayv2_integration.signin.id}"

}

resource "aws_lambda_permission" "api_gw_signin" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signin_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}


#########################################################
############ CountWords API GW Integration ##############
#########################################################

resource "aws_apigatewayv2_integration" "countWords" {
  api_id = aws_apigatewayv2_api.apigw.id

  integration_uri    = aws_lambda_function.countWords_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

}

resource "aws_apigatewayv2_route" "countWords" {
  api_id = aws_apigatewayv2_api.apigw.id

  route_key = "POST /countWords"
  target    = "integrations/${aws_apigatewayv2_integration.countWords.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.apigw_auth.id
}

resource "aws_lambda_permission" "api_gw_countWords" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.countWords_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}


