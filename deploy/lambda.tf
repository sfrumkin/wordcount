data "archive_file" "signup_lambda_package" {  
  type = "zip"  
  source_file = "${path.module}/../src/signup.py" 
  output_path = "signup.zip"
}

resource "aws_lambda_function" "signup_lambda_function" {
        function_name = "signUp"
        filename      = "signup.zip"
        source_code_hash = data.archive_file.signup_lambda_package.output_base64sha256
        role          = aws_iam_role.lambda_role.arn
        runtime       = "python3.9"
        handler       = "signup.lambda_handler"
        timeout       = 20
}