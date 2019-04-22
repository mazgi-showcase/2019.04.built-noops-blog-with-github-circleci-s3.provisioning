variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

variable "service_name" {
  default = "engineers-blog"
}

variable "default_env_name" {
  default = "external"
}

variable "envs" {
  default = [
    "external", # https://example.jp/
    "review",   # review environment for external and internal
    "internal",
  ]
}
