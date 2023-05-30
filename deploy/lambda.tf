#########################################################
################ SignUp Lambda ##########################
#########################################################
data "archive_file" "signup_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/../src/signup.py"
  output_path = "signup.zip"
}

resource "aws_lambda_function" "signup_lambda_function" {
  function_name    = "signUp"
  filename         = "signup.zip"
  source_code_hash = data.archive_file.signup_lambda_package.output_base64sha256
  role             = aws_iam_role.signup_role.arn
  runtime          = "python3.9"
  handler          = "signup.lambda_handler"
  timeout          = 20


  environment {
    variables = {
      COGNITO_USER_POOL_ID       = aws_cognito_user_pool.wordcount_user_pool.id
      COGNITO_POOL_CLIENT_ID     = aws_cognito_user_pool_client.wordcount_user_pool_client.id
      COGNITO_POOL_CLIENT_SECRET = aws_cognito_user_pool_client.wordcount_user_pool_client.client_secret
      REGION                     = var.aws_region
    }
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-signup"
    },
  )
}

#########################################################
################ PreSignUp Lambda #######################
#########################################################


data "archive_file" "preSignup_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/../src/preSignup.py"
  output_path = "preSignup.zip"

}

resource "aws_lambda_function" "preSignup_lambda_function" {
  function_name    = "preSignUp"
  filename         = "preSignup.zip"
  source_code_hash = data.archive_file.preSignup_lambda_package.output_base64sha256
  role             = aws_iam_role.signup_role.arn
  runtime          = "python3.9"
  handler          = "preSignup.lambda_handler"
  timeout          = 10

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-preSignup"
    },
  )

}

resource "aws_lambda_permission" "preSignUp" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.preSignup_lambda_function.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.wordcount_user_pool.arn

}

#########################################################
################ Signin Lambda ##########################
#########################################################
data "archive_file" "signin_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/../src/signin.py"
  output_path = "signin.zip"
}

resource "aws_lambda_function" "signin_lambda_function" {
  function_name    = "signin"
  filename         = "signin.zip"
  source_code_hash = data.archive_file.signin_lambda_package.output_base64sha256
  role             = aws_iam_role.signin_role.arn
  runtime          = "python3.9"
  handler          = "signin.lambda_handler"
  timeout          = 20

  environment {
    variables = {
      COGNITO_USER_POOL_ID       = aws_cognito_user_pool.wordcount_user_pool.id
      COGNITO_POOL_CLIENT_ID     = aws_cognito_user_pool_client.wordcount_user_pool_client.id
      COGNITO_POOL_CLIENT_SECRET = aws_cognito_user_pool_client.wordcount_user_pool_client.client_secret
      REGION                     = var.aws_region
    }
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-signin"
    },
  )
}

#########################################################
################ WordCount Lambda ##########################
#########################################################
data "archive_file" "wordcount_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/../src/countWords.py"
  output_path = "countWords.zip"
}

resource "aws_lambda_function" "countWords_lambda_function" {
  function_name    = "countWords"
  filename         = "countWords.zip"
  source_code_hash = data.archive_file.wordcount_lambda_package.output_base64sha256
  role             = aws_iam_role.wordcount_role.arn
  runtime          = "python3.9"
  handler          = "countWords.lambda_handler"
  timeout          = 60

  environment {
    variables = {
      BUCKET_NAME = random_pet.bucket_name.id
      REGION      = var.aws_region
    }
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-countWords"
    },
  )
}

