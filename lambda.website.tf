data "aws_iam_policy_document" "website-lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "website-lambda-assume-role" {
  name               = "website-lambda-assume-role"
  assume_role_policy = "${data.aws_iam_policy_document.website-lambda-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "website-lambda-assume-role-policy-attachment" {
  role       = "${aws_iam_role.website-lambda-assume-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "website-lambda-redirect-to-index-document" {
  type        = "zip"
  source_dir  = "lambda-sources/redirect-to-index-document"
  output_path = "lambda-arhives/redirect-to-index-document.zip"
}

resource "aws_lambda_function" "website-lambda-redirect-to-index-document" {
  filename         = "${data.archive_file.website-lambda-redirect-to-index-document.output_path}"
  function_name    = "website-lambda-redirect-to-index-document"
  role             = "${aws_iam_role.website-lambda-assume-role.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.website-lambda-redirect-to-index-document.output_base64sha256}"
  runtime          = "nodejs8.10"
  publish          = true
}
