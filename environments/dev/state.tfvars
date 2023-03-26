bucket         = "terraform-sandbox-fjv8zhdssginpd6i"
# I've disabled state locking for simplicity - but if you ever use this in a shared environment 100% use this
# https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-state-locking
# dynamodb_table = "tf_state_lock"
key            = "static-site/environment/dev.tfstate"
region         = "ap-southeast-2"
