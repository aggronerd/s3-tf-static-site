# Sample Static Website on AWS 

This is a very quick example of how to get a static website up and running using Terraform and AWS Simple Storage 
Service (S3). This is useful if you just want to get a website serving static HTML without much of the cost and fuss, 
but are **not** concerned with custom domains, security, dynamic server-side rendering or advanced routing.

[Here is an example of this site](http://aggronerds-site.s3-website-ap-southeast-2.amazonaws.com/)!

## Why?

### Pros
* S3 is very cheap (in Sydney it's presently U$0.025 per GB)
* S3 is managed, meaning you don't need to worry about server upkeep and 
  [SLAs provided by Amazon](https://aws.amazon.com/s3/sla/)

### Cons
* **No HTTPS** out-of-the-box (need to use Cloudfront or Cloudflare in front of it, for example).
* Getting a custom domain requires more work. Currently, you get a custom sub-domain.
* Won't support dynamic server-side rendered sites (PHP, Ruby, Python, Go etc.)
* No real monitoring or metrics on how the site is used.

## Usage

### Prerequisites

1. **Checkout this code** to a local folder and put your static site content in the `html/` folder or use the example 
   HTML.
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
   The bucket is private by default but the name needs to be globally unique.
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
2. Run the following to initialise the environment:
   ```bash
   make tfinit
   ```
3. Run the following and review the output, these are the change that will be performed on your AWS account.
   ```bash
   make plan
   ```
4. If you're happy with the "plan" run the following to create the environment:
   ```bash
   make apply
   ```
5. The output of the changes includes the URL for the new environment, you can fetch it directly by running:
   ```bash
   terraform output website_url
   ```
   Follow that link, and you will be on the site.

Since this uploads the files for the site you can continue to make changes within this repository and run `plan` and 
`apply` to push changes to the site. It's not a conventional workflow for website design, you might opt instead to
upload files to the S3 bucket via a CI pipeline job and the `aws s3` CLI interface. In which case you may want to
empty the `html` folder as changes to those files are tracked by Terraform.

### Cleaning Up

The following will remove all traces of this site ensuring you have set `ENV` environment variable to the value of the 
environment you wish to tear-down.

1. Run the following to initialise the environment:
   ```bash
   make tfinit
   ```
2. Run the following to destroy all the resources using Terraform:
   ```bash
   make destroy
   ```
   You will be prompted to type "yes" to confirm you want to destroy the resources
3. Delete the state S3 bucket defined in the value of `bucket` in the environments `state.tfvar` file, eg.
   [environments/example/state.tfvars](./environments/example/state.tfvars). This can be done via the AWS CLI, eg:
   ```bash
   aws s3 rm s3://terraform-sandbox-tbzpjfj354dshfpj --recursive
   aws s3api delete-bucket \
     --region ap-southeast-2 \
     --bucket terraform-sandbox-tbzpjfj354dshfpj
   ```
   
## Background

### Why this Approach?

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
   GitOps flow processes and push the latest version of the site to a Kubernetes cluster. If it was part of a complex
   microservices approach I'd opt to use Helm Charts to define the versions of the microservices. This would support
   server-side rendering and would allow anyone to create a site so long as their service listens on port 80, for 
   example. Bonuses:
   1. Can use cluster ingress such as nginx-ingress or Istio.
   2. Can use cert manager (LetsEncrypt) for example to quickly set up HTTPS.
   3. Can integrate metrics and monitoring (Prometheus).
   4. GitOps flow ensures releases are deployed.
2. Use a managed service that offers HTTPS and custom domains. GitHub offers GitHub Pages, for example.
3. Within the AWS eco-system there's Fargate which would allow serverless deployment of a Docker container similar to 
   (1), you can then use ECR for private container registries, Application Load Balancer (ALB) for providing a
   HTTPs endpoint on top of which you can implement CloudFront.
4. Quite simply starting up an EC2 instance running nginx is one option but you've got a bit more to manage in the long
   run compared to containerised approaches. For example managing the machine image it's running on in terms of
   libraries and kernel updates to the OS. Between Kubernetes and other proprietary container orchestration you've got
   easy alternatives but requires know-how in your team to support it.


   