resource "aws_cognito_user_pool" "wordcount_user_pool" {
  name = "wordCountUserPool"

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  lambda_config {
    pre_sign_up = (terraform.workspace == "dev") ? aws_lambda_function.preSignup_lambda_function.arn : null
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message_by_link = "Please use the following link to confirm: {##Click Here##}"
    email_subject_by_link = "Please confirm your email address"
  }

  password_policy {
    temporary_password_validity_days = 7
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-wordcount_user_pool"
    },
  )

}

resource "aws_cognito_user_pool_client" "wordcount_user_pool_client" {
  name                = "wordcountUserPoolClient"
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]

  generate_secret = true

  user_pool_id = aws_cognito_user_pool.wordcount_user_pool.id

}

resource "random_pet" "domain_name" {
  prefix = "domain"
  length = 4
}

resource "aws_cognito_user_pool_domain" "wordcount" {
  domain       = random_pet.domain_name.id
  user_pool_id = aws_cognito_user_pool.wordcount_user_pool.id
}

