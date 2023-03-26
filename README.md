# Sample Static Website on AWS 

This is a very quick example of how to get a static website up and running using Terraform and AWS Simple Storage 
Service (S3). This is useful if you just want to get a website serving static HTML without much of the cost and fuss, 
but are **not** concerned with custom domains, security, dynamic server-side rendering or advanced routing.

## Why?

### Pros
* S3 is very cheap (in Sydney it's presently U$0.025 per GB)
* S3 is managed, meaning you don't need to worry about server upkeep and 
  [SLAs provided by Amazon](https://aws.amazon.com/s3/sla/)

### Cons
* **No HTTPS** out-of-the-box (need to use Cloudfront or Cloudflare in front of it for example)
* Getting a custom domain requires more work. This will give you a custom sub-domain.
* Won't support dynamic server side rendered sites (PHP, Ruby, Python, Go etc.)

## Usage

### Prerequisites

1. **Checkout this code** checked out to a local folder and put your static site content in the `html/` folder.
2. [**Terraform**](https://developer.hashicorp.com/terraform/downloads) downloaded and installed (see the required 
   version in [.terraform_version](./.terraform-version))
3. **An AWS account**. The best way is to ensure you've installed the [AWS command-line interface (CLI)](https://aws.amazon.com/cli/) and 
   configured it to access your account. Terraform will automatically use the same profile, which will basically need
   Admin permissions to S3.
4. GNU `make` installed and working from the command line (Mac OS: `brew install make`, Debian: `sudo apt install make`)
   
### Setup

1. You'll need an S3 bucket for storing the state unless you opt for another solution (by configuration in
   [state.tf](./state.tf)). The quickest way is to pick a random hard to guess suffix and create the bucket using the 
   AWS CLI, for example:
   ```bash
   aws s3api create-bucket  \
    --bucket terraform-sandbox-tbzpjfj354dshfpj \
    --region ap-southeast-2 \
    --create-bucket-configuration LocationConstraint=ap-southeast-2
   ```
2. When you've created the bucket you will need to set the value of `bucket` in 
   [environments/example/state.tfvars](./environments/example/state.tfvars).
3. Update the variable `site_name` in [environments/example/variables.tfvars](./environments/example/variables.tfvars)
   to a unique value for your site.

### Running

Having set up the environment you can now run the Terraform via the Makefile.

1. Set the ENV environment variable to the target for the deployment, eg:
   ```bash
   export ENV=example
   ```
2. Run `make tfinit` to initialise the environment.
3. Run `make plan` and review the output, these are the change that will be performed on your AWS account.
4. If you're happy with the "plan" run `make apply` to create the environment.
5. The output of the changes includes the URL for the new environment, you can fetch it directly by running:
   ```bash
   terraform output website_url
   ```
   Follow that link, and you will be on the site.

Since this uploads the files for the site you can continue to make changes within this repository and run `plan` and 
`apply` to push changes to the site. It's not a conventional workflow for website design, you might opt instead to
upload files to the S3 bucket via a CI pipeline job and the `aws s3` CLI interface. In which case you may want to
empty the `html` folder.

### Cleanup

The following will remove all traces of this site

1. Run `make tfinit` to initialise the environment.
2. Run `make destroy`.
3. Delete the state S3 bucket defined in the value of `bucket` in the environments `state.tfvar` file, eg.
   [environments/example/state.tfvars](./environments/example/state.tfvars). This can be done via the AWS CLI, eg:
   ```bash
   
   ```
   
## Background

### Why this approach

* S3 is cheap.
* This is quicker than some alternatives detailed below.

### Improving this Approach

* Add Cloudfront to the config along with Route53 records and ACM certificate validation. That way giving custom domain
  names and HTTPS.
* Using Cloudfront to add regional caches in the world reducing latency for visitors.
* Enabling logging on the S3 website to give some access information and metrics, however this could conflict with 
  Cloudfront which would provide better metrics.
* Use DynamoDB to lock the state for the environments. This is only disabled to simplify this example. 

### Alternatives

1. My preferred approach would be a CI pipeline compiling a Docker image for the site. That CI pipeline would trigger 
   Gitflow processes and push the latest version of the site to a Kubernetes cluster. If it was part of a complex
   microservices approach I'd opt to use Helm Charts to define the versions of the microservices. This would support
   server-side rendering and would allow anyone to create a site so long as their service listens on port 80, for 
   example. Bonuses:
   2. 