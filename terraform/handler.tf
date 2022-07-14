resource "aws_lambda_function" "terraform-lambda-demo" {
    function_name = "terraform-lambda-demo"

    ##### Roles and security #####
    role = "arn:aws:iam::596346144973:role/iam_for_test_lambda"
    # security_group_ids = # (Required) List of security group IDs associated with the Lambda function.
    # subnet_ids = # (Required) List of subnet IDs associated with the Lambda function.


    ##### Code #####
    # Source code from S3
    s3_bucket = "apfie-people"
    s3_key = "asen/examples/terraform-lambda-demo.zip"

    # Source code from zip file
    # filename = "lambda_function_payload.zip"
    # source_code_hash = filebase64sha256("lambda_function_payload.zip")

    # Source code from image
    # image_config =
    # image_uri = # ECR image URI containing the function's deployment package.

    # Entry point
    handler = "handler.handler"


    ##### Runtime Environment #####
    # runtime = "nodejs12.x"

    ##### Env Variables #####
    runtime = "nodejs16.x"
    # environment {
    #     variables = {
    #         foo = "bar"
    #     }
    # }
}
