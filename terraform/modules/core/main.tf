// The AWS provider reads access key/secret and region from the environment
// variables AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION as
// set by our wrapper script, bin/tf

provider "aws" {
}
