# Installation

Fork this repo, and edit to customize for your desired aws setup.

Install terraform: `brew install terraform`
Install jq: `brew install jq`
Install awscli: `pip install awscli`

# Authoring terraform config

AWS can be a tangled web of dependencies.  For the simpler things, feel free to author directly in terraform.  For something more complicated, it can be helpful to author using the aws web console, then walk the generated entities and mirror them in a terraform config.  If the aws entities you are creating are supported by the [terraforming](https://github.com/dtan4/terraforming) gem, then it is helpful to use it to generate the equivalent terraform config and/or state

# Terraform binaries

Sometimes it is neccessary to use an unreleased version of terraform to get access to recently added resource types.  To get those binaries, run `bin/tf_build`.  By default, it will pull the latest version of master from the terraform repo, and build the binaries for OSX.  It requires a working vagrant and virtualbox on your system.

# General usage

* Setup: Configure aws cli with your ops user: `aws configure`
* Plan: `TF_ENV=env ./bin/tf plan`
* Verify the above output
* Apply: `TF_ENV=env ./bin/tf apply`

Note that if you have multiple aws cli profiles, you can either set the default profile with `export AWS_DEFAULT_PROFILE=myprofile` or add it to the command line for tf: `AWS_DEFAULT_PROFILE=myprofile TF_ENV=env ./bin/tf plan`

# Aws cli usage

The credentials you use when configuring the aws cli should be the access key/secret you can generate for your primary ops account (IAM -> Users -> You -> Security Credentials -> Create Access Key).  Once you have run `aws configure` and input these secrets, you can then run the cli against the other environments by using the `bin/assume_role` script, e.g. `./bin/assume_role staging aws s3 ls`  The `bin/tf` script will automatically do this for running the terraform binaries using the assumed role credentials for each environment.


# Setup from Zero

## Ops account

* Create ops account
* Record AWS account number in only aws_accounts in `terraform/environments/variables.tf`
* Get an access key/secret for an ops admin account
* Bootstrap ops: `AWS_ACCESS_KEY_ID=“<ops_bootstrap_acct_key>“ AWS_SECRET_ACCESS_KEY="<ops_bootstrap_acct_secret>” TF_ENV=ops ./bin/tf bootstrap`
* Create your ops user
* Configure aws cli with your ops user: `aws configure`
* Apply ops: `TF_ENV=ops ./bin/tf apply`

## Env account

* Create env account
* Record AWS account number in env_accounts_csv and aws_accounts in `terraform/environments/variables.tf`
* Get an access key/secret for an env admin account
* Add sections to ops for env in terraform/environments/ops/iam.tf
* Apply ops: `TF_ENV=ops ./bin/tf apply`
* Create `terraform/environments/<env_name>` (copy from `terraform/environments/env-account-template`)
* Make edits to `terraform/enviroments/<env_name>(-secret).tfvars` specific to your new environment
* Create keypair `acme-<env_name>-main` in env AWS account
  * Store private key in ~/.ssh
  * Set permissions on private key: `chmod 600 ~/.ssh/acme-<env_name>-main.pem`
  * Generate public key: `ssh-keygen -y -f ~/.ssh/acme-<env_name>-main.pem > ~/.ssh/acme-<env_name>-main.pem.pub`
* Bootstrap env: `AWS_ACCESS_KEY_ID=“<env_bootstrap_acct_key>“ AWS_SECRET_ACCESS_KEY="<env_bootstrap_acct_secret>” TF_ENV=env_name ./bin/tf bootstrap`
* Apply env: `TF_ENV=env_name ./bin/tf apply`

## Adding a new user

* Edit terraform/environments/ops/iam.tf to add the user and assign to groups
* Use aws console to setup login credentials and give to user
* User logs in and generates access keys for self
* User runs`aws configure` to setup aws cli with above access key/secret
* Verify working with `TF_ENV=dev ./bin/tf plan`
* Add role switchers in console (see below) for each account you have access to
* Add vpn access (see below) for user in each env they should have vpn access to

## Per-User Role switcher in Console

Login to the AWS console with your personal aws account that was created by ops.  Select the dropdown with your email at top right of aws console, Switch Role.  Fill the details for the enironment you want to be able to access from the console:

* Account number for the environment (See aws_accounts in [variables.tf](terraform/environments/variables.tf)
* Role `ops-admin` - this is the role you assume in the destination account, it has the same value of `ops-admin` for all accounts
* Pick a name (e.g. DevAdmin)
* Pick a color that you like (e.g. Red=production, Yellow=staging, Green=dev)

## Managing secrets

Secrets are read from `terraform/environments/<env>/terraform-secret.tfvars` if it exists, otherwise they are read from `s3://acme-ops-terraform/<env>/terraform-secret.tfvars`.  To update secrets for each env, you can pull down and work with a local copy, then commit it back to s3:

* `TF_ENV=<env> ./bin/tf secrets fetch`
* Edit `terraform/environments/<env>/terraform-secret.tfvars`
* Verify new local secrets work
* `TF_ENV=<env> ./bin/tf secrets save`
* Verify new remote secrets work
* Delete `terraform/environments/<env>/terraform-secret.tfvars.backup` so you don't have secrets lying around on disk more than is neccessary
* If you don't have permissions to staging/production, coordinate with someone that does to get the secrets added there as well

## VPN access

To see usage for the vpn utility:

    ./bin/vpn

To generate a new vpn client, use the vpn script to first create the new client (take note of the passphrase displayed), then fetch the client config file to feed into the vpn client software.  You can use any string for `<client_name>` but the user's email address makes for a reasonable choice.

    ./bin/vpn newclient <client_name>
    # Record the passphrase from ^
    ./bin/vpn getclient <client_name>
    # VPN client config will then be found in: <client_name>.ovpn

[Tunnelblick](https://tunnelblick.net/downloads.html) is a decent vpn client that is verified to work with our vpn.  Once installed, you can then double click on the `ovpn` config file to add the connection.

To show all enabled VPN clients, run:

    ./bin/vpn listclient


To revoke VPN access, run:

    ./bin/vpn revokeclient <client_name>

Note that this needs to restart the vpn server, so anyone currently connected will need to reconnect.
