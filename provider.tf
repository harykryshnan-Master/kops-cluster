# States and what-not
provider "aws" {
    region = "us-east-1"
    profile = "default"
}

# Own state
# State lock is managed by 'terraform-state-lock' DynamoDB table
# Hence it avoids any race-conditions or multi user manipulations to the state file at the same time
# If the the state is locked - can get it unlocked using "terraform force-unlock <LockID> "
terraform {
  backend "s3" {
    bucket = "bayes-esports-assignment-tfstate-bucket"
    key = "terraform-state-files/prod/prod.terraform.tfstate"
    region = "us-east-1"
    profile = "default"
    dynamodb_table = "terraform-state-lock"
  }

 required_providers {
   aws = {
    source = "hashicorp/aws"
   }
 }

}



