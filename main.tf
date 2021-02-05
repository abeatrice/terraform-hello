provider "aws" {
  region = "us-west-1"
}

provider "archive" {}

data "archive_file" "zip" {
  type = "zip"
  source_file = "handler.js"
  output_path = "handler.zip"
}

data "aws_iam_policy_document" "policy" {
  statement {
      sid = ""
      effect = "Allow"

      principals {
          identifiers = ["lambda.amazonaws.com"]
          type = "Service"
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "hello_lambda"
  filename = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "handler.hello"
  runtime = "nodejs12.x"
}
