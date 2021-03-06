resource "null_resource" "npm_install" {
  triggers = {
    lambda_hash = timestamp()
  }

  provisioner "local-exec" {
    command = "cd ./../lambda && npm i"
  }
}

data "archive_file" "terraform-lambda-demo-zip" {
    depends_on = [null_resource.npm_install]
    type = "zip"
    # source_dir = "${path.root}/../lambda"
    source_dir = "./../lambda/"
    output_path = "./terraform-lambda-demo.zip"
}

resource "aws_s3_object" "terraform-lambda-demo-s3" {
    bucket = "apfie-people"
    key = "asen/examples/terraform-lambda-demo.zip"
    source = data.archive_file.terraform-lambda-demo-zip.output_path
    etag = data.archive_file.terraform-lambda-demo-zip.output_md5
}

resource "aws_lambda_function" "terraform-lambda-demo" {
    function_name = "terraform-lambda-demo"
    role = "arn:aws:iam::596346144973:role/iam_for_test_lambda"
    s3_bucket = "apfie-people"
    s3_key = aws_s3_object.terraform-lambda-demo-s3.key
    handler = "handler.handler"
    runtime = "nodejs16.x"
    source_code_hash = data.archive_file.terraform-lambda-demo-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "terraform-lambda-demo" {
    name = "/aws/lambda/${aws_lambda_function.terraform-lambda-demo.function_name}"
    retention_in_days = 30
}

resource "aws_lambda_function_url" "terraform-lambda-demo-url" {
  function_name      = aws_lambda_function.terraform-lambda-demo.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

resource "aws_lambda_permission" "invoke_function_url" {
  statement_id           = "InvokeFunctionUrl-Terraform"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.terraform-lambda-demo.function_name
  function_url_auth_type = "NONE"
  principal              = "*"
}

output "function-url" {
    value = aws_lambda_function_url.terraform-lambda-demo-url.function_url
}
