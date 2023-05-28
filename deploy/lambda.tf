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
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "signup.lambda_handler"
  timeout          = 60

  vpc_config {
    subnet_ids         = [aws_subnet.lambda-vpc-subnet-private.id]
    security_group_ids = [aws_security_group.lambda-vpc-sg.id]
  }


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
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "preSignup.lambda_handler"
  timeout          = 10

  vpc_config {
    subnet_ids         = [aws_subnet.lambda-vpc-subnet-private.id]
    security_group_ids = [aws_security_group.lambda-vpc-sg.id]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-preSignup"
    },
  )
}