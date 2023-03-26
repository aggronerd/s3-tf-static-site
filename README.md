# Sample Static Website on AWS 

This is a very quick example of how to get a static website up and running using Terraform and AWS Simple Storage 
Service (S3).

## Why?

### Pros
* S3 is very cheap 
* S3 is managed and 


### Cons
* No HTTPS with cst
* Won't support dynamic server side rendered sites (PHP, Ruby, Python, Go etc.)



## Setting the site

### Prerequisites

1. **This code** checked out to a local folder.
2. [**Terraform**](https://developer.hashicorp.com/terraform/downloads) (see the required version in 
   [.terraform_version](./.terraform-version))
3. **An AWS account**. The best way is to ensure you've installed the [AWS CLI](https://aws.amazon.com/cli/) and 
   configured it to access your account. Terraform will automatically use the same profile, which will need write 
   access to S3 and DynamoDB.
   
### Setup

1. You'll need an S3 bucket for storing the state unless you opt for another solution. The quickest way is to pick a 
   random hard to guess suffix and create the bucket using the AWS cli:
   ```bash
   aws s3api create-bucket  \
    --bucket terraform-sandbox-fjv8zhdssginpd6i \
    --region ap-southeast-2 \
    --create-bucket-configuration LocationConstraint=ap-southeast-2
   ```
   

### Cleanup

1. Run `make destroy`
1. Delete the S3 bucket we created earlier
   
## Background

### Why this approach

* S3 is cheap