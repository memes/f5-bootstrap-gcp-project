# F5 project bootstrap

This repo is used to prepare existing F5 GCP projects for Terraform and Ansible
automation. During execution, Terraform will bootstrap the project to create
these resources:

1. Terraform GCS bucket for remote state
1. Enables Compute Engine and IAP APIs by default
1. Enables OS Login for GCE instances at the project level
1. A service account to use for Terraform automation
   - with storage admin rights on Terraform state bucket
   - with an extendible set of roles at project level
   - with optional impersonation enabled for AD group(s)
1. A service account to use for Ansible automation
   - with an extendible set of roles at project level
   - with optional impersonation enabled for AD group(s)
1. Initialises Secret Manager and stores the JSON credential files for Terraform
   and Ansible service accounts

## Usage

This repo uses file based environment configurations in preference to Terraform
workspaces. Per-environment configurations are stored in
`env/ENV/name.{config,tfvars}`, where ENV and name represents the GCP project
enviornment to manage.

### To make a change to an **existing** project

To make changes to an existing project to add additional impersonation groups,
or to enable other GCP APIs

1. Fork the repo
1. Edit the relevant environment `tfvars` file
1. Execute standard Terraform process

   ```shell
   $ terraform init -backend-config env/ENV/name.config
   $ terraform plan -var-file env/ENV/name.tfvars
   $ terraform apply -var-file env/ENV/name.tfvars
   ```
1. Push the changes to GitHub and open a PR to merge to `master`

### To bootstrap a **new** project

If you need to bootstrap a new GCP project to support Terraform automation:

1. Fork the repo
1. Create a new `env` folder for the project, with a `config` and `tfvar` file.
   - Edit the new `tfvar` file and set `project_id` to match the target GCP
     project id
   - Add AD groups that will be granted the ability to impersonate Terraform
     service account
   - Add AD groups that will be able to retrieve Ansible service account
     credentials from Secret Manager
   - *Optional:* Add any Google Cloud APIs that need to be enabled
   - *Optional:* Add any additional roles that should be granted to the
     Terraform and/or Ansible service accounts
1. Comment out line 12 [`main.tf`](main.tf#L12) to disable the GCS backend; this
   will be reverted after the state bucket is bootstrapped.
1. Execute Terraform to create the new resources

   ```shell
   $ terraform plan -var-file env/ENV/name.tfvars
   $ terraform apply -var-file env/ENV/name.tfvars
   ...
   tf_sa = terraform@PROJECT_ID.iam.gserviceccount.com
   ...
   tf_state_bucket = TF_BUCKET_NAME
   ```

1. Uncomment line 12 [`main.tf`](main.tf#L12) to enable GCS backend
   1. Edit the new `config` environment file and add the Terraform state bucket that was an ouput from step 4
   1. Add a unique prefix for the bootstrap state
   E.g.

   ```hcl
   bucket = "TF_BUCKET_NAME"
   prefix = "foundations/terraform-bootstrap"
   ```

1. Reinitialise Terraform to migrate the state to GCS bucket

   ```shell
   $ terraform init -backend-config env/ENV/name.config
   ...
   Initializing the backend...
   Do you want to copy existing state to the new backend?
      Pre-existing state was found while migrating the previous "local" backend to the newly configured "gcs" backend. No existing state was found in the newly configured "gcs" backend. Do you want to copy this state to the new "gcs" backend? Enter "yes" to copy and "no" to start with an empty state.

      Enter a value: yes

   Successfully configured the backend "gcs"! Terraform will automatically use this backend unless the backend configuration changes.
   ...
   ```

   The Terraform state is now stored in GCS bucket and can be shared by others that are managing the project.
1. Commit and push the changes to GitHub, and open a PR to merge to `master`

## Environments

1. [F5 Sales project](env/f5-sales/)
   Non-Shared VPC project used by multiple engineers in the Sales organization.
1. [F5 Sales Shared VPC projects](env/f5-sales-shared-vpc/)
   Projects setup as a Shared VPC host and service pair. Note that this environment has separate config pairs for the host and service project.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| google | ~> 3.14 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ansible\_sa\_creds\_secret\_id | The unique identifier to use for Ansible credential store in Secret Manager.<br>Default is 'ansible-creds'. | `string` | `"ansible-creds"` | no |
| ansible\_sa\_creds\_secret\_readers | A list of accounts that will be granted read-only access to the Ansible JSON<br>credentials in Secret Manager. Default is an empty list.<br><br>NOTE: this variable is less opinionated and is a raw list of accounts that will<br>be granted read-only access; each account must be prefixed with 'group:',<br>'serviceAccount:', or 'user:' as appropriate.<br><br>E.g.<br>ansible\_sa\_creds\_secret\_readers = [<br>  "group:devsecops@example.com",<br>  "serviceAccount:my-service@PROJECT\_ID.iam.gserviceaccount.com",<br>  "user:jane\_doe@example.com",<br>] | `list(string)` | `[]` | no |
| ansible\_sa\_impersonate\_groups | A list of groups that will be allowed to impersonate the Ansible service account.<br>If no groups are supplied, impersonation will not be setup by the script.<br><br>NOTE: Ansible does not directly support impersonation; prefer<br>`ansible_sa_creds_secret_readers` to add accounts permitted to read the Ansible<br>SA JSON credentials.<br><br>E.g.<br>ansible\_sa\_impersonate\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| ansible\_sa\_name | The name of the Ansible service account to add to the project. Default is<br>'ansible'. | `string` | `"ansible"` | no |
| ansible\_sa\_roles | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, and IAM assignments. | `list(string)` | <pre>[<br>  "roles/compute.viewer",<br>  "roles/compute.osLogin"<br>]</pre> | no |
| apis | An optional list of GCP APIs to enable in the project. | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "iap.googleapis.com",<br>  "oslogin.googleapis.com",<br>  "iam.googleapis.com",<br>  "iamcredentials.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| oslogin\_groups | A list of groups that will be allowed to use OS Login to VMs.<br>E.g.<br>oslogin\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| project\_id | The existing project id that will have a Terraform service account added. | `string` | n/a | yes |
| tf\_bucket\_location | The location where the bucket will be created; this could be a GCE region, or a<br>dual-region or multi-region specifier. Default is to create a multi-region bucket<br>in 'US'. | `string` | `"US"` | no |
| tf\_bucket\_name | The name of a GCS bucket to create for Terraform state storage. This name must be<br>unique in GCP. If blank, (the default), the name will be 'tf-PROJECT\_ID', where<br>PROJECT\_ID is the unique project identifier. | `string` | `""` | no |
| tf\_sa\_creds\_secret\_id | The unique identifier to use for Terraform credential store in Secret Manager.<br>Default is 'terraform-creds'. | `string` | `"terraform-creds"` | no |
| tf\_sa\_creds\_secret\_readers | A list of accounts that will be granted read-only access to the Terraform JSON<br>credentials in Secret Manager. Default is an empty list. Terraform fully<br>supports impersonation; prefer `tf_sa_impersonate_groups` to add groups<br>permitted to impersonate Terraform SA.<br><br>NOTE: this variable is less opinionated and is a raw list of accounts that will<br>be granted read-only access; each account must be prefixed with 'group:',<br>'serviceAccount:', or 'user:' as appropriate.<br><br>E.g.<br>tf\_sa\_creds\_secret\_readers = [<br>  "group:devsecops@example.com",<br>  "serviceAccount:my-service@PROJECT\_ID.iam.gserviceaccount.com",<br>  "user:jane\_doe@example.com",<br>] | `list(string)` | `[]` | no |
| tf\_sa\_impersonate\_groups | A list of groups that will be allowed to impersonate the Terraform service account.<br>If no groups are supplied, impersonation will not be setup by the script.<br>E.g.<br>tf\_sa\_impersonate\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| tf\_sa\_name | The name of the Terraform service account to add to the project. Default is<br>'terraform'. | `string` | `"terraform"` | no |
| tf\_sa\_roles | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, IAM, and Secret Manager assignments. | `list(string)` | <pre>[<br>  "roles/compute.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/storage.admin",<br>  "roles/resourcemanager.projectIamAdmin",<br>  "roles/iam.serviceAccountUser",<br>  "roles/secretmanager.admin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| ansible\_sa | The fully-qualified Ansible service account identifier. |
| ansible\_sa\_secret\_id | The unique secret ID to access Ansible JSON credentials. |
| tf\_sa | The fully-qualified Terraform service account identifier. |
| tf\_sa\_secret\_id | The unique secret ID to access Terraform JSON credentials. |
| tf\_state\_bucket | The GCS bucket that will hold Terraform state. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
