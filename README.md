# Integrating Regula with Scalr
## Regula for IaC Security :handshake: Scalr for Terraform Automation and Collaboration

### Introduction to Regula and Scalr
#### Regula
[Regula](https://regula.dev/index.html) is a tool that evaluates infrastructure as code files for potential AWS, Azure, Google Cloud, and Kubernetes security and compliance violations prior to deployment.
Regula is an open source project maintained by [Fugue](https://www.fugue.co/) engineers.

#### Scalr
[Scalr](https://www.scalr.com/home-navattic) is a remote state & operations backend for terraform with full CLI support, integration with OPA, a hierarchical configuration model, and quality of life features.

### Goal
Pair Regula's powerful, easy-to-use IaC scanning capabilities and Scalr's terraform automation and collaboration capabilities to automate the *secure* deployment of cloud infrastructure with terraform.

### Preparation
I started by signing up for a [free Scalr trial account](https://scalr.io/#/public/signup). Upon request, Scalr was kind enough to grant me trial access to the premium [Custom Hooks](https://docs.scalr.com/en/latest/workspaces.html#custom-hooks) feature, which allowed me to customize my terraform workflow. Next, I created a [workspace](https://docs.scalr.com/en/latest/workspaces.html#create-workspace), added my [AWS credentials](https://docs.scalr.com/en/latest/cloud_credentials.html#provider-credentials) (very convenient not to have to include these in my terraform `.gitignore` file and instead have Scalr automate the authentication with AWS), and added a version control system (VCS) [provider](https://docs.scalr.com/en/latest/vcs_providers.html#vcs-providers) (I used GitHub). Finally, I downloaded the latest version of Regula from the [Regula GitHub repository](https://github.com/fugue/regula/releases) (use the Linux x86_64 release for compatability with Scalr). If you want to follow along, you can clone my repository:

```git clone https://github.com/aidan-fugue/fugue-scalr-integration.git```

The final step in preparation is assigning the `before-plan.bash` and `after-plan.bash` as the pre and post `terraform plan` custom hooks.
This way, whenever I commit and push a new version of my infrastructure to my GitHub repostory, Scalr will automatically trigger the standard terraform build with the addition of my customizations.

### What's in the repo?
![file structure](/img/tree.png "file structure")   

What you see above is a visual representation of the file structure for the above repo, which contains terraform files in `main.tf` and `/s3/`, scripts that will be run as custom hooks in `/scripts/`, and rule waivers in `waivers.rego`.

A note on waivers: I have decided to waive Fugue rules `FG_R00274` (bucket logging must be enabled for all S3 buckets) and `FG_R00275` (cross-region replication for S3 buckets) to demonstrate a situation in which it would be appropriate to waive rules, and another in which it would be appropriate to disable rules (see comments in waivers below):

```re
package fugue.regula.config

waivers[waiver] {
  waiver := {
    #Waiving bucket logging (logging bucket)
    "rule_id": "FG_R00274",
    "resource_id": "module.s3.aws_s3_bucket.logbucket"
  }
}

rules[rule] {
  rule := {
    #Disabling cross region replication (budgetary purposes)
    "rule_id": "FG_R00275",
    "status": "DISABLED"
  }
}
```

### Stopping misconfigurations from getting to the cloud
Regula and Scalr work together below to stop misconfigured infrastructure from being deployed to the cloud, producing a non-zero exit code if the following commands throw any errors:
```bash
./regula run --include waivers.rego
terraform validate
```

#### Trying (and failing) a build
When I try to run...
```
git add <files>
git commit -m "initiating the scalr terraform pipeline"
git push
```
...Scalr will detect that I have commited changes to my repository, and will call Regula to scan my IaC for security and compliance issues:

![failed build](/img/failed_build.gif "failed build")

#### Resolving configuration issues with Regula

Now that I know I have misconfigurations in my terraform files, I can go back into my repo in VSCode and execute a `regula run` locally to address those issues.
Alternatively, I could export the output of the `regula run` that occurred in my Scalr run.
I set up this repository to allow me to un-comment my terraform code corrections easily, but properly configuring your infrasructure is as easy as clicking the hyperlink that populates with every rule following a `regula run`.
See below for how I fixed Fugue rules `FG_R00036` and `FG_R00101`, then re-checked my infrasructure with a final `regula run`.

![fixing regula issues](/img/fixing_issues.gif "fixing issues")

#### Trying (and succeeding!) a build

With my infrastructure properly configured, I'll commit to my GitHub repository again to maximize Scalr's terraform automation capability.
This will run my `before_plan.bash` script to ensure I pass `terraform validate` and `regula run`, then (if that is successful) Scalr will run `terraform plan`.
Following this, Scalr will use my next custom hook to run my next script (`after_plan.bash`) to ensure each `.tf` file is formatted according to the HCL canonical standard (`terraform fmt`).
This is a cool terraform feature that will automatically fix formatting issues (see below for this in action -- I purposefully left some errors to demonstrate this):

![terraform fmt](/img/terraform_fmt.gif "proper .tf formatting")

I'll re-run the commands I ran initially...
```
git add <files>
git commit -m "initiating the scalr terraform pipeline"
git push
```
...resulting in a successful build:

![successful build](/img/successful_build.gif "successful build")

And that's it! Now we have a Regula/Scalr pipeline to securely automate the deployment of cloud infrastructure using terraform.
