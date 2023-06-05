
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.apigw.invoke_url
}


output "user_pool_id" {
  description = "Cognito user pool id."

  value = aws_cognito_user_pool.wordcount_user_pool.id
}
